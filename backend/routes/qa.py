from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection
from groq import Groq
import os
import json
import faiss
import numpy as np
from sentence_transformers import SentenceTransformer
from pathlib import Path

qa_bp = Blueprint('qa', __name__)

groq_client = Groq(api_key=os.getenv('GROQ_API_KEY'))

BASE_DIR = Path(__file__).parent.parent / 'backend'
DATA_DIR = BASE_DIR / 'data'

try:
    embedding_model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')
    index = faiss.read_index(str(DATA_DIR / 'faiss_index.bin'))
    with open(DATA_DIR / 'metadata.json', 'r', encoding='utf-8') as f:
        chunks = json.load(f)
    RAG_READY = True
    print(f"✅ RAG system loaded: {len(chunks)} chunks")
except Exception as e:
    RAG_READY = False
    print(f"❌ RAG system failed to load: {e}")


# ─────────────────────────────────────────────────────────────────
# SCOPE FILTERING
# Determines which chunk indices are allowed based on scope
# scope = 'topic'   → only chunks matching topic_id
# scope = 'chapter' → only chunks matching chapter_id topics
# scope = 'all'     → all chunks (no filter)
# ─────────────────────────────────────────────────────────────────
def get_allowed_indices(scope, topic_id=None, chapter_id=None):
    """Returns set of allowed chunk indices based on scope."""
    if scope == 'all' or (not topic_id and not chapter_id):
        return set(range(len(chunks)))

    allowed = set()

    for i, chunk in enumerate(chunks):
        chunk_topic = chunk.get('topic_id', '')
        if not chunk_topic:
            # Try to extract topic_id from citation like "Chapter 1, Topic 1.2, Paragraph 1"
            citation = chunk.get('citation', '')
            if 'Topic' in citation:
                try:
                    topic_part = citation.split('Topic')[1].strip().split(',')[0].strip()
                    chunk_topic = topic_part
                except:
                    pass

        if scope == 'topic' and topic_id:
            if chunk_topic == topic_id:
                allowed.add(i)

        elif scope == 'chapter' and chapter_id:
            # chapter_id is integer like 1, 2, 3...
            # topic_ids in that chapter start with "{chapter_id}."
            if chunk_topic.startswith(f"{chapter_id}."):
                allowed.add(i)

    # Fallback — if filtering returned nothing, return all
    if not allowed:
        return set(range(len(chunks)))

    return allowed


def retrieve_chunks_scoped(question, top_k=5, scope='all', topic_id=None, chapter_id=None):
    """FAISS search with scope filtering."""
    allowed_indices = get_allowed_indices(scope, topic_id, chapter_id)

    query_embedding = embedding_model.encode([question])
    query_embedding = np.array(query_embedding).astype('float32')

    # Search more candidates then filter
    search_k = min(len(chunks), top_k * 10)
    distances, indices = index.search(query_embedding, search_k)

    candidates = []
    for i, idx in enumerate(indices[0]):
        if idx < len(chunks) and idx in allowed_indices:
            candidates.append((distances[0][i], chunks[idx], idx))

    if not candidates:
        return []

    # Score with keyword boosting
    scored = []
    question_lower = question.lower()
    for distance, chunk, chunk_idx in candidates:
        score = 1.0 / (distance + 0.1)
        text_lower = chunk['text'].lower()
        words = [w for w in question_lower.split() if len(w) > 4]
        matches = sum(1 for w in words if w in text_lower)
        if matches > 0:
            score *= (1 + matches * 1.5)
        scored.append((score, chunk, chunk_idx))

    scored.sort(reverse=True, key=lambda x: x[0])
    return [chunk for score, chunk, idx in scored[:top_k]]


def generate_answer_groq(question, retrieved_chunks, scope, topic_name=None, chapter_name=None):
    context = '\n\n'.join([c['text'] for c in retrieved_chunks[:4]])

    if scope == 'topic' and topic_name:
        scope_instruction = f"Answer ONLY using information about '{topic_name}'. If the question is about a different topic, politely say this topic is not covered here and suggest the student navigate to the relevant topic."
    elif scope == 'chapter' and chapter_name:
        scope_instruction = f"Answer using information from the '{chapter_name}' chapter only. If the question is about content from a different chapter, politely say it's not covered in this chapter."
    else:
        scope_instruction = "Answer using the provided course content."

    response = groq_client.chat.completions.create(
        model='llama-3.3-70b-versatile',
        messages=[
            {
                'role': 'system',
                'content': (
                    'You are an expert O-Level Chemistry tutor for EduTailor. '
                    f'{scope_instruction} '
                    'Be clear, concise and educational. '
                    'Keep answers to 3-4 sentences maximum. '
                    'If the answer is not in the content, say so honestly.'
                )
            },
            {
                'role': 'user',
                'content': f"""Textbook Content:
{context[:3000]}

Student Question: {question}

Answer based on the textbook content above:"""
            }
        ],
        temperature=0.2,
        max_tokens=300,
    )

    return response.choices[0].message.content.strip()


@qa_bp.route('/ask', methods=['POST'])
@jwt_required()
def ask_question():
    user_id = int(get_jwt_identity())
    data = request.get_json()
    question = data.get('question', '').strip()

    # Scope parameters
    topic_id   = data.get('topic_id')    # e.g. "1.1"
    chapter_id = data.get('chapter_id')  # e.g. 1 (integer)
    scope      = data.get('scope', 'all')  # 'topic', 'chapter', or 'all'

    # Extra context for better prompting
    topic_name   = data.get('topic_name')
    chapter_name = data.get('chapter_name')

    if not question:
        return jsonify({'error': 'Question is required'}), 400

    if not RAG_READY:
        return jsonify({'error': 'Q&A system not available'}), 503

    try:
        retrieved = retrieve_chunks_scoped(
            question,
            top_k=5,
            scope=scope,
            topic_id=topic_id,
            chapter_id=str(chapter_id) if chapter_id else None
        )

        if not retrieved:
            answer = "I don't have information about that in the current scope. Please try rephrasing your question."
            citation = None
            sources = []
        else:
            answer = generate_answer_groq(question, retrieved, scope, topic_name, chapter_name)
            sources = list({
                c.get('citation', c.get('section', 'Course Content'))
                for c in retrieved[:3]
            })
            citation = ', '.join(sources[:3]) if sources else 'Course Content'

        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO student_questions
            (user_id, topic_id, question_text, answer_text, citation)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id
        """, (user_id, topic_id, question, answer, citation))
        question_id = cursor.fetchone()['id']
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'question_id': question_id,
            'question': question,
            'answer': answer,
            'citation': citation,
            'sources': sources[:3],
        })

    except Exception as e:
        import traceback
        traceback.print_exc()
        return jsonify({'error': f'Failed to generate answer: {str(e)}'}), 500


@qa_bp.route('/history', methods=['GET'])
@jwt_required()
def get_history():
    user_id = int(get_jwt_identity())
    topic_id = request.args.get('topic_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    if topic_id:
        cursor.execute("""
            SELECT id, question_text, answer_text, citation, asked_at
            FROM student_questions
            WHERE user_id = %s AND topic_id = %s
            ORDER BY asked_at DESC LIMIT 20
        """, (user_id, topic_id))
    else:
        cursor.execute("""
            SELECT id, question_text, answer_text, citation, asked_at
            FROM student_questions
            WHERE user_id = %s
            ORDER BY asked_at DESC LIMIT 20
        """, (user_id,))

    questions = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify({'questions': [dict(q) for q in questions]})


@qa_bp.route('/helpful', methods=['POST'])
@jwt_required()
def mark_helpful():
    user_id = int(get_jwt_identity())
    data = request.get_json()
    question_id = data.get('question_id')
    was_helpful = data.get('was_helpful', True)

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE student_questions
        SET was_helpful = %s
        WHERE id = %s AND user_id = %s
    """, (was_helpful, question_id, user_id))
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Feedback recorded'})