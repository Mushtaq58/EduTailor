from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection

topics_bp = Blueprint('topics', __name__)


@topics_bp.route('/topics', methods=['GET'])
@jwt_required()
def get_topics():
    chapter_id = request.args.get('chapter_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    if chapter_id:
        cursor.execute("""
            SELECT t.topic_id, t.topic_name, t.visual_type, c.title as chapter_name
            FROM topics t
            JOIN chapters c ON c.id = t.chapter_id
            WHERE t.chapter_id = %s
            ORDER BY t.topic_id
        """, (chapter_id,))
    else:
        cursor.execute("""
            SELECT t.topic_id, t.topic_name, t.visual_type, c.title as chapter_name
            FROM topics t
            JOIN chapters c ON c.id = t.chapter_id
            ORDER BY t.topic_id
        """)

    topics = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify({
        'topics': [
            {
                'id': t['topic_id'],
                'title': t['topic_name'],
                'chapter_name': t['chapter_name'],
                'visual_type': t['visual_type'],
            }
            for t in topics
        ]
    })


@topics_bp.route('/progress', methods=['GET'])
@jwt_required()
def get_progress():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT topic_id, status
        FROM student_progress
        WHERE user_id = %s
    """, (user_id,))
    progress = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({
        'progress': [
            {'topic_id': p['topic_id'], 'status': p['status']}
            for p in progress
        ]
    })


@topics_bp.route('/topics/<topic_id>', methods=['GET'])
@jwt_required()
def get_topic(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT t.topic_id, t.topic_name, t.visual_type,
               t.paragraph_1, t.paragraph_2, t.paragraph_3,
               t.paragraph_4, t.paragraph_5,
               t.urdu_paragraph_1, t.urdu_paragraph_2, t.urdu_paragraph_3,
               t.urdu_paragraph_4, t.urdu_paragraph_5,
               t.audio_en_path, t.visual_path,
               t.visual_narration,
               c.title as chapter_name
        FROM topics t
        JOIN chapters c ON c.id = t.chapter_id
        WHERE t.topic_id = %s
    """, (topic_id,))
    topic = cursor.fetchone()

    if not topic:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    cursor.execute("""
        SELECT status FROM student_progress
        WHERE user_id = %s AND topic_id = %s
    """, (user_id, topic_id))
    existing = cursor.fetchone()

    if existing:
        if existing['status'] == 'not_started':
            cursor.execute("""
                UPDATE student_progress
                SET status = 'in_progress', last_accessed = NOW()
                WHERE user_id = %s AND topic_id = %s
            """, (user_id, topic_id))
    else:
        cursor.execute("""
            INSERT INTO student_progress (user_id, topic_id, status, last_accessed)
            VALUES (%s, %s, 'in_progress', NOW())
        """, (user_id, topic_id))

    conn.commit()

    cursor.execute("""
        SELECT status FROM student_progress
        WHERE user_id = %s AND topic_id = %s
    """, (user_id, topic_id))
    progress = cursor.fetchone()
    status = progress['status'] if progress else 'in_progress'

    paragraphs = [
        topic['paragraph_1'], topic['paragraph_2'],
        topic['paragraph_3'], topic['paragraph_4'],
        topic['paragraph_5'],
    ]
    english_content = '\n'.join(p for p in paragraphs if p)

    urdu_paragraphs = [
        topic['urdu_paragraph_1'], topic['urdu_paragraph_2'],
        topic['urdu_paragraph_3'], topic['urdu_paragraph_4'],
        topic['urdu_paragraph_5'],
    ]
    urdu_content = '\n'.join(p for p in urdu_paragraphs if p) or None

    cursor.close()
    conn.close()

    return jsonify({
        'topic': {
            'id': topic['topic_id'],
            'title': topic['topic_name'],
            'chapter_name': topic['chapter_name'],
            'visual_type': topic['visual_type'],
            'status': status,
            'english_content': english_content,
            'urdu_content': urdu_content,
            'audio_url': topic['audio_en_path'],
            'visual_narration': topic['visual_narration'],
            'visual_url': topic['visual_path'],
        }
    })


@topics_bp.route('/topics/<topic_id>/complete', methods=['POST'])
@jwt_required()
def mark_complete(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT status FROM student_progress
        WHERE user_id = %s AND topic_id = %s
    """, (user_id, topic_id))
    existing = cursor.fetchone()

    if existing:
        cursor.execute("""
            UPDATE student_progress
            SET status = 'completed', completed_at = NOW()
            WHERE user_id = %s AND topic_id = %s
        """, (user_id, topic_id))
    else:
        cursor.execute("""
            INSERT INTO student_progress (user_id, topic_id, status, completed_at)
            VALUES (%s, %s, 'completed', NOW())
        """, (user_id, topic_id))

    conn.commit()
    cursor.close()
    conn.close()
    return jsonify({'message': 'Topic marked as completed'})


@topics_bp.route('/topics/<topic_id>/generate', methods=['POST'])
@jwt_required()
def generate_content(topic_id):
    data = request.get_json()
    content_type = data.get('type')
    return jsonify({'message': f'{content_type} generation triggered', 'status': 'queued'})


@topics_bp.route('/chapters', methods=['GET'])
@jwt_required()
def get_chapters():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT c.id, c.chapter_number, c.title, c.description,
               COUNT(t.topic_id) as topic_count
        FROM chapters c
        LEFT JOIN topics t ON t.chapter_id = c.id
        GROUP BY c.id, c.chapter_number, c.title, c.description
        ORDER BY c.chapter_number
    """)
    chapters = cursor.fetchall()
    cursor.close()
    conn.close()
    return jsonify({'chapters': [dict(c) for c in chapters]})


@topics_bp.route('/topics/content-status', methods=['GET'])
@jwt_required()
def get_content_status():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    if not user or user['role'] != 'teacher':
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT
            t.topic_id, t.topic_name, t.visual_type,
            t.urdu_paragraph_1,
            t.audio_en_path, t.visual_path,
            t.visual_narration,
            cs_urdu.status as urdu_status,
            cs_audio_en.status as audio_en_status,
            cs_visual.status as visual_status,
            cs_narration.status as visual_narration_status
        FROM topics t
        LEFT JOIN content_status cs_urdu
            ON cs_urdu.topic_id = t.topic_id AND cs_urdu.content_type = 'urdu'
        LEFT JOIN content_status cs_audio_en
            ON cs_audio_en.topic_id = t.topic_id AND cs_audio_en.content_type = 'audio_en'
        LEFT JOIN content_status cs_visual
            ON cs_visual.topic_id = t.topic_id
            AND cs_visual.content_type IN ('animation', 'diagram')
        LEFT JOIN content_status cs_narration
            ON cs_narration.topic_id = t.topic_id AND cs_narration.content_type = 'visual_narration'
        ORDER BY t.topic_id
    """)
    topics = cursor.fetchall()
    cursor.close()
    conn.close()

    result = []
    for t in topics:
        result.append({
            'topic_id': t['topic_id'],
            'topic_name': t['topic_name'],
            'visual_type': t['visual_type'],
            'urdu_ready': bool(t['urdu_paragraph_1']),
            'audio_en_ready': bool(t['audio_en_path']),
            'visual_ready': bool(t['visual_path']),
            'visual_narration_ready': bool(t['visual_narration']),
            'urdu_status': t['urdu_status'] or 'not_generated',
            'audio_en_status': t['audio_en_status'] or 'not_generated',
            'visual_status': t['visual_status'] or 'not_generated',
            'visual_narration_status': t['visual_narration_status'] or 'not_generated',
        })

    return jsonify({'topics': result})