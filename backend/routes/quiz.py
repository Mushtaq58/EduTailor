from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection
from groq import Groq
import json
import os
import random

quiz_bp = Blueprint('quiz', __name__)

groq_client = Groq(api_key=os.getenv('GROQ_API_KEY'))


@quiz_bp.route('/generate', methods=['POST'])
@jwt_required()
def generate_quiz():
    user_id = int(get_jwt_identity())
    data = request.get_json()
    topic_id = data.get('topic_id')

    if not topic_id:
        return jsonify({'error': 'topic_id is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT topic_name, paragraph_1, paragraph_2, paragraph_3, paragraph_4
        FROM topics WHERE topic_id = %s
    """, (topic_id,))
    topic = cursor.fetchone()

    if not topic:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    paragraphs = [
        topic['paragraph_1'], topic['paragraph_2'],
        topic['paragraph_3'], topic['paragraph_4']
    ]
    content = '\n\n'.join(p for p in paragraphs if p)

    random_seed = random.randint(1, 999999)
    focus_areas = [
        "definitions and terminology",
        "properties and characteristics",
        "real-world examples and applications",
        "comparisons and contrasts",
        "cause and effect relationships",
        "mechanisms and processes"
    ]
    random_focus = random.sample(focus_areas, 3)

    prompt = f"""Generate a UNIQUE chemistry quiz for O-Level students on the topic: {topic['topic_name']}

Content:
{content}

UNIQUENESS SEED: {random_seed}
FOCUS AREAS FOR THIS ATTEMPT: {', '.join(random_focus)}

Create a quiz with exactly 5 multiple choice questions and exactly 2 subjective questions.
Focus specifically on the focus areas listed above to ensure variety across attempts.
Do NOT generate predictable or obvious questions — vary the angle and depth each time.

Return ONLY valid JSON with no markdown, no backticks, no extra text:
{{
  "mcq": [
    {{
      "id": "mcq_1",
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correct_answer": "A",
      "explanation": "Brief explanation"
    }},
    {{
      "id": "mcq_2",
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correct_answer": "B",
      "explanation": "Brief explanation"
    }},
    {{
      "id": "mcq_3",
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correct_answer": "C",
      "explanation": "Brief explanation"
    }},
    {{
      "id": "mcq_4",
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correct_answer": "D",
      "explanation": "Brief explanation"
    }},
    {{
      "id": "mcq_5",
      "question": "Question text here?",
      "options": ["A) Option 1", "B) Option 2", "C) Option 3", "D) Option 4"],
      "correct_answer": "A",
      "explanation": "Brief explanation"
    }}
  ],
  "subjective": [
    {{
      "id": "sub_1",
      "question": "Question text here?",
      "reference_answer": "Expected answer here"
    }},
    {{
      "id": "sub_2",
      "question": "Second question here?",
      "reference_answer": "Expected answer here"
    }}
  ]
}}

Requirements:
- correct_answer must be exactly one of: A, B, C, or D
- Questions must test understanding not memorization
- Base ALL questions on the provided content only
- Use simple O-Level appropriate language
- Vary question styles: some factual, some application-based, some analytical
- Return ONLY the JSON object, nothing else"""

    try:
        response = groq_client.chat.completions.create(
            model='llama-3.3-70b-versatile',
            messages=[
                {
                    'role': 'system',
                    'content': 'You are an expert O-Level chemistry teacher. Generate unique quiz questions based strictly on the provided content. Every quiz attempt must have different questions. Return only valid JSON with no markdown formatting.'
                },
                {
                    'role': 'user',
                    'content': prompt
                }
            ],
            temperature=0.9,
            max_tokens=3000,
        )

        quiz_text = response.choices[0].message.content.strip()

        if quiz_text.startswith('```'):
            quiz_text = quiz_text.split('\n', 1)[1]
        if quiz_text.endswith('```'):
            quiz_text = quiz_text.rsplit('```', 1)[0]
        quiz_text = quiz_text.strip()

        quiz_data = json.loads(quiz_text)

        cursor.execute("""
            SELECT format FROM format_tracking
            WHERE user_id = %s AND topic_id = %s
            ORDER BY session_date DESC LIMIT 1
        """, (user_id, topic_id))
        fmt_row = cursor.fetchone()
        format_used = fmt_row['format'] if fmt_row else 'english'

        cursor.execute("""
            INSERT INTO quiz_attempts
            (user_id, topic_id, format_used, mcq_score, subjective_score,
             total_score, mcq_responses, subjective_responses)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            user_id, topic_id, format_used, 0, 0, 0,
            json.dumps({'answers': quiz_data['mcq']}),
            json.dumps({'answers': quiz_data['subjective']})
        ))
        attempt_id = cursor.fetchone()['id']
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'attempt_id': attempt_id,
            'topic_title': topic['topic_name'],
            'mcq_questions': [
                {
                    'id': q['id'],
                    'question_text': q['question'],
                    'options': [
                        opt.split(') ', 1)[1] if ') ' in opt else opt
                        for opt in q['options']
                    ],
                }
                for q in quiz_data['mcq']
            ],
            'subjective_questions': [
                {
                    'id': q['id'],
                    'question_text': q['question'],
                }
                for q in quiz_data['subjective']
            ]
        }), 200

    except json.JSONDecodeError as e:
        conn.close()
        return jsonify({'error': f'Failed to parse quiz JSON: {str(e)}'}), 500
    except Exception as e:
        import traceback
        traceback.print_exc()
        conn.close()
        return jsonify({'error': f'Quiz generation failed: {str(e)}'}), 500


@quiz_bp.route('/submit', methods=['POST'])
@jwt_required()
def submit_quiz():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    attempt_id = data.get('attempt_id')
    mcq_answers = data.get('mcq_answers', {})
    subjective_answers = data.get('subjective_answers', {})

    if not attempt_id:
        return jsonify({'error': 'attempt_id is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT mcq_responses, subjective_responses, topic_id, format_used
        FROM quiz_attempts WHERE id = %s AND user_id = %s
    """, (attempt_id, user_id))
    attempt = cursor.fetchone()

    if not attempt:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Attempt not found'}), 404

    mcq_responses = attempt['mcq_responses']
    sub_responses = attempt['subjective_responses']

    if isinstance(mcq_responses, str):
        mcq_responses = json.loads(mcq_responses)
    if isinstance(sub_responses, str):
        sub_responses = json.loads(sub_responses)

    stored_mcq = mcq_responses['answers']
    stored_sub = sub_responses['answers']
    topic_id = attempt['topic_id']
    format_used = attempt['format_used']

    mcq_correct = 0
    question_results = {}

    for q in stored_mcq:
        qid = q['id']
        student_ans = mcq_answers.get(qid, '')
        correct = q['correct_answer']
        is_correct = student_ans.strip().upper() == correct.strip().upper()
        if is_correct:
            mcq_correct += 1
        question_results[qid] = {
            'correct_answer': correct,
            'student_answer': student_ans,
            'correct': is_correct,
            'explanation': q.get('explanation', ''),
        }

    mcq_score = round((mcq_correct / len(stored_mcq)) * 100) if stored_mcq else 0

    try:
        from sentence_transformers import SentenceTransformer
        from numpy import dot
        from numpy.linalg import norm
        model = SentenceTransformer('sentence-transformers/all-MiniLM-L6-v2')

        sub_scores = []
        for q in stored_sub:
            qid = q['id']
            student_ans = subjective_answers.get(qid, '')
            reference = q['reference_answer']

            if not student_ans.strip():
                score = 0.0
            else:
                s_emb = model.encode([student_ans])[0]
                r_emb = model.encode([reference])[0]
                similarity = float(dot(s_emb, r_emb) / (norm(s_emb) * norm(r_emb)))
                score = max(0.0, min(1.0, similarity))

            sub_scores.append(score)
            question_results[qid] = {
                'score': round(score * 100),
                'explanation': f'Your answer matched the expected response at {round(score * 100)}% similarity.',
            }

        subjective_score = round((sum(sub_scores) / len(sub_scores)) * 100) if sub_scores else 0

    except Exception:
        subjective_score = 50
        for q in stored_sub:
            question_results[q['id']] = {
                'score': 50,
                'explanation': 'Automatic grading unavailable.',
            }

    total_score = round((mcq_score * 0.5) + (subjective_score * 0.5))

    cursor.execute("""
        UPDATE quiz_attempts
        SET mcq_score = %s, subjective_score = %s, total_score = %s
        WHERE id = %s
    """, (mcq_score, subjective_score, total_score, attempt_id))

    cursor.execute("""
        UPDATE student_progress
        SET best_score = GREATEST(COALESCE(best_score, 0), %s),
            attempts_count = COALESCE(attempts_count, 0) + 1,
            status = CASE WHEN %s >= 70 THEN 'completed' ELSE status END
        WHERE user_id = %s AND topic_id = %s
    """, (total_score, total_score, user_id, topic_id))

    try:
        cursor.execute("""
            UPDATE format_tracking
            SET quiz_score_after = %s
            WHERE user_id = %s AND topic_id = %s AND format = %s
            AND id = (
                SELECT id FROM format_tracking
                WHERE user_id = %s AND topic_id = %s AND format = %s
                ORDER BY session_date DESC LIMIT 1
            )
        """, (total_score, user_id, topic_id, format_used,
              user_id, topic_id, format_used))
    except Exception:
        pass

    conn.commit()
    cursor.close()
    conn.close()

    try:
        from services.adaptive_engine import update_recommendation
        update_recommendation(user_id)
    except Exception as e:
        import traceback
        print(f'Adaptive engine error: {e}')
        traceback.print_exc()

    return jsonify({
        'score': total_score,
        'mcq_score': mcq_score,
        'subjective_score': subjective_score,
        'passed': total_score >= 70,
        'question_results': question_results,
    })


@quiz_bp.route('/attempts', methods=['GET'])
@jwt_required()
def get_attempts():
    user_id = int(get_jwt_identity())
    topic_id = request.args.get('topic_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    if topic_id:
        cursor.execute("""
            SELECT id, topic_id, mcq_score, subjective_score, total_score, attempted_at
            FROM quiz_attempts WHERE user_id = %s AND topic_id = %s
            ORDER BY attempted_at DESC
        """, (user_id, topic_id))
    else:
        cursor.execute("""
            SELECT id, topic_id, mcq_score, subjective_score, total_score, attempted_at
            FROM quiz_attempts WHERE user_id = %s
            ORDER BY attempted_at DESC
        """, (user_id,))

    attempts = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify({'attempts': [dict(a) for a in attempts]})