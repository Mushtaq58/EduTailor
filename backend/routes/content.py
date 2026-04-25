from flask import Blueprint, jsonify, request, send_from_directory
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection
from services.content_service import (
    generate_urdu_translation,
    generate_english_audio,
    generate_animation,
    generate_diagram,
    generate_visual_narration,
)
from services.lecture_service import generate_full_lecture
import os
from pathlib import Path

content_bp = Blueprint('content', __name__)

MEDIA_DIR = Path(__file__).parent.parent / 'media'


def require_teacher(cursor, user_id):
    cursor.execute("SELECT role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    return user and user['role'] == 'teacher'


# =====================================================
# MEDIA SERVING
# =====================================================

@content_bp.route('/media/audio/<filename>')
def serve_audio(filename):
    return send_from_directory(MEDIA_DIR / 'audio', filename)


@content_bp.route('/media/animations/<filename>')
def serve_animation(filename):
    return send_from_directory(MEDIA_DIR / 'animations', filename)


@content_bp.route('/media/diagrams/<filename>')
def serve_diagram(filename):
    return send_from_directory(MEDIA_DIR / 'diagrams', filename)


@content_bp.route('/media/lectures/<filename>')
def serve_lecture_audio(filename):
    return send_from_directory(MEDIA_DIR / 'lectures', filename)


# =====================================================
# CONTENT STATUS
# Update 8: Added lecture_status, mindmap_status
# =====================================================

@content_bp.route('/topics/content-status', methods=['GET'])
@jwt_required()
def get_content_status():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT
            t.topic_id, t.topic_name, t.visual_type,
            t.urdu_paragraph_1,
            t.audio_en_path, t.visual_path,
            t.visual_narration,
            t.mindmap_json,
            cs_urdu.status       AS urdu_status,
            cs_audio_en.status   AS audio_en_status,
            cs_visual.status     AS visual_status,
            cs_narration.status  AS visual_narration_status,
            cs_lecture.status    AS lecture_status,
            cs_mindmap.status    AS mindmap_status
        FROM topics t
        LEFT JOIN content_status cs_urdu
            ON cs_urdu.topic_id = t.topic_id AND cs_urdu.content_type = 'urdu'
        LEFT JOIN content_status cs_audio_en
            ON cs_audio_en.topic_id = t.topic_id AND cs_audio_en.content_type = 'audio_en'
        LEFT JOIN content_status cs_visual
            ON cs_visual.topic_id = t.topic_id AND cs_visual.content_type IN ('animation', 'diagram')
        LEFT JOIN content_status cs_narration
            ON cs_narration.topic_id = t.topic_id AND cs_narration.content_type = 'visual_narration'
        LEFT JOIN content_status cs_lecture
            ON cs_lecture.topic_id = t.topic_id AND cs_lecture.content_type = 'lecture'
        LEFT JOIN content_status cs_mindmap
            ON cs_mindmap.topic_id = t.topic_id AND cs_mindmap.content_type = 'mindmap'
        ORDER BY t.topic_id
    """)
    topics = cursor.fetchall()
    cursor.close()
    conn.close()

    # Build a set of topic_ids that have actual lecture slides in DB
    conn2 = get_db_connection()
    cur2 = conn2.cursor()
    cur2.execute("""
        SELECT DISTINCT topic_id FROM lecture_slides
    """)
    topics_with_slides = {row['topic_id'] for row in cur2.fetchall()}
    cur2.close()
    conn2.close()

    result = []
    for t in topics:
        # lecture_ready = has actual slides in DB (source of truth)
        lecture_ready = t['topic_id'] in topics_with_slides
        mindmap_ready = bool(t['mindmap_json'])

        # Sync content_status if out of sync — slides exist but no status entry
        lecture_status = t['lecture_status'] or 'not_generated'
        if lecture_ready and lecture_status == 'not_generated':
            lecture_status = 'pending_review'

        result.append({
            'topic_id': t['topic_id'],
            'topic_name': t['topic_name'],
            'visual_type': t['visual_type'],
            'urdu_ready': bool(t['urdu_paragraph_1']),
            'audio_en_ready': bool(t['audio_en_path']),
            'visual_ready': bool(t['visual_path']),
            'visual_narration_ready': bool(t['visual_narration']),
            'lecture_ready': lecture_ready,
            'mindmap_ready': mindmap_ready,
            'urdu_status': t['urdu_status'] or 'not_generated',
            'audio_en_status': t['audio_en_status'] or 'not_generated',
            'visual_status': t['visual_status'] or 'not_generated',
            'visual_narration_status': t['visual_narration_status'] or 'not_generated',
            'lecture_status': lecture_status,
            'mindmap_status': t['mindmap_status'] or 'not_generated',
        })

    return jsonify({'topics': result})


# =====================================================
# URDU TRANSLATION
# =====================================================

@content_bp.route('/topics/<topic_id>/generate-urdu', methods=['POST'])
@jwt_required()
def gen_urdu(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5
        FROM topics WHERE topic_id = %s
    """, (topic_id,))
    topic = cursor.fetchone()

    if not topic:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    paragraphs = [topic[f'paragraph_{i}'] for i in range(1, 6) if topic[f'paragraph_{i}']]

    try:
        urdu_paragraphs = generate_urdu_translation(topic_id, paragraphs)

        set_clause = ', '.join([f'urdu_paragraph_{i} = %s' for i in range(1, len(urdu_paragraphs[:5]) + 1)])
        cursor.execute(
            f"UPDATE topics SET {set_clause} WHERE topic_id = %s",
            [*urdu_paragraphs[:5], topic_id]
        )

        cursor.execute("""
            INSERT INTO content_status (topic_id, content_type, status, generated_at)
            VALUES (%s, 'urdu', 'pending_review', NOW())
            ON CONFLICT (topic_id, content_type)
            DO UPDATE SET status = 'pending_review', generated_at = NOW()
        """, (topic_id,))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'message': 'Urdu translation generated successfully',
            'paragraphs': urdu_paragraphs,
        })

    except Exception as e:
        cursor.close()
        conn.close()
        return jsonify({'error': str(e)}), 500


# =====================================================
# ENGLISH AUDIO — Edge TTS en-GB-RyanNeural
# =====================================================

@content_bp.route('/topics/<topic_id>/generate-audio-en', methods=['POST'])
@jwt_required()
def gen_audio_en(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5
        FROM topics WHERE topic_id = %s
    """, (topic_id,))
    topic = cursor.fetchone()

    if not topic:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    paragraphs = [topic[f'paragraph_{i}'] for i in range(1, 6) if topic[f'paragraph_{i}']]

    try:
        file_path, url_path = generate_english_audio(topic_id, paragraphs)

        cursor.execute(
            "UPDATE topics SET audio_en_path = %s WHERE topic_id = %s",
            (url_path, topic_id)
        )
        cursor.execute("""
            INSERT INTO content_status (topic_id, content_type, status, file_path, generated_at)
            VALUES (%s, 'audio_en', 'pending_review', %s, NOW())
            ON CONFLICT (topic_id, content_type)
            DO UPDATE SET status = 'pending_review', file_path = %s, generated_at = NOW()
        """, (topic_id, url_path, url_path))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'message': 'English audio generated successfully',
            'audio_url': url_path,
        })

    except Exception as e:
        cursor.close()
        conn.close()
        return jsonify({'error': str(e)}), 500


# =====================================================
# GENERATE VISUAL (animation or diagram)
# Update 3: Also generates visual_narration
# =====================================================

@content_bp.route('/topics/<topic_id>/generate-visual', methods=['POST'])
@jwt_required()
def gen_visual(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT topic_name, visual_type,
               paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5
        FROM topics WHERE topic_id = %s
    """, (topic_id,))
    topic = cursor.fetchone()

    if not topic:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    paragraphs = [topic[f'paragraph_{i}'] for i in range(1, 6) if topic[f'paragraph_{i}']]

    try:
        if topic['visual_type'] == 'animation':
            file_path, url_path = generate_animation(topic_id, topic['topic_name'], paragraphs)
            content_type_val = 'animation'
        else:
            file_path, url_path = generate_diagram(topic_id, topic['topic_name'], paragraphs)
            content_type_val = 'diagram'

        narration_text = generate_visual_narration(topic_id, topic['topic_name'], paragraphs)

        cursor.execute("""
            UPDATE topics
            SET visual_path = %s, visual_narration = %s
            WHERE topic_id = %s
        """, (url_path, narration_text, topic_id))

        cursor.execute("""
            INSERT INTO content_status (topic_id, content_type, status, file_path, generated_at)
            VALUES (%s, %s, 'pending_review', %s, NOW())
            ON CONFLICT (topic_id, content_type)
            DO UPDATE SET status = 'pending_review', file_path = %s, generated_at = NOW()
        """, (topic_id, content_type_val, url_path, url_path))

        cursor.execute("""
            INSERT INTO content_status (topic_id, content_type, status, generated_at)
            VALUES (%s, 'visual_narration', 'pending_review', NOW())
            ON CONFLICT (topic_id, content_type)
            DO UPDATE SET status = 'pending_review', generated_at = NOW()
        """, (topic_id,))

        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'message': f'{content_type_val.capitalize()} and visual narration generated successfully',
            'visual_url': url_path,
            'visual_type': content_type_val,
            'visual_narration': narration_text,
        })

    except Exception as e:
        cursor.close()
        conn.close()
        return jsonify({'error': str(e)}), 500


# =====================================================
# UPDATE 8: GENERATE LECTURE
# (slides + audio + mindmap in one call)
# Teacher only — stored permanently, served to all students
# =====================================================

@content_bp.route('/topics/<topic_id>/generate-lecture', methods=['POST'])
@jwt_required()
def gen_lecture(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    # Verify topic exists
    cursor.execute("SELECT topic_id FROM topics WHERE topic_id = %s", (topic_id,))
    if not cursor.fetchone():
        cursor.close()
        conn.close()
        return jsonify({'error': 'Topic not found'}), 404

    cursor.close()

    try:
        result = generate_full_lecture(conn, topic_id)
        conn.close()

        return jsonify({
            'message': f"Lecture generated: {result['slides_generated']} slides, "
                       f"{result['audio_generated']} audio files, "
                       f"mindmap {'ready' if result['mindmap_generated'] else 'failed'}",
            'slides_generated': result['slides_generated'],
            'audio_generated': result['audio_generated'],
            'mindmap_generated': result['mindmap_generated'],
        })

    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


# =====================================================
# UPDATE 8: GET LECTURE SLIDES
# Students fetch slides from DB — zero API calls
# =====================================================

@content_bp.route('/topics/<topic_id>/lecture-slides', methods=['GET'])
@jwt_required()
def get_lecture_slides(topic_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT slide_number, title, bullets, audio_ur_path
        FROM lecture_slides
        WHERE topic_id = %s
        ORDER BY slide_number ASC
    """, (topic_id,))
    rows = cursor.fetchall()
    cursor.close()
    conn.close()

    if not rows:
        return jsonify({'slides': [], 'has_lecture': False})

    slides = []
    for row in rows:
        audio_url = None
        if row['audio_ur_path']:
            audio_url = f"http://localhost:5000/api/{row['audio_ur_path']}"

        slides.append({
            'slide_number': row['slide_number'],
            'title': row['title'],
            'bullets': row['bullets'],  # already list from JSONB
            'audio_url': audio_url,
        })

    return jsonify({'slides': slides, 'has_lecture': True})


# =====================================================
# UPDATE 8: GET MINDMAP
# =====================================================

@content_bp.route('/topics/<topic_id>/mindmap', methods=['GET'])
@jwt_required()
def get_mindmap(topic_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute(
        "SELECT mindmap_json FROM topics WHERE topic_id = %s",
        (topic_id,)
    )
    row = cursor.fetchone()
    cursor.close()
    conn.close()

    if not row or not row['mindmap_json']:
        return jsonify({'mindmap': None, 'has_mindmap': False})

    return jsonify({
        'mindmap': row['mindmap_json'],
        'has_mindmap': True
    })


# =====================================================
# APPROVE / REJECT CONTENT
# =====================================================

@content_bp.route('/topics/<topic_id>/approve', methods=['POST'])
@jwt_required()
def approve_content(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    content_type = data.get('content_type')

    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        UPDATE content_status
        SET status = 'approved', approved_by = %s, approved_at = NOW()
        WHERE topic_id = %s AND content_type = %s
    """, (user_id, topic_id, content_type))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': f'{content_type} approved'})


@content_bp.route('/topics/<topic_id>/reject', methods=['POST'])
@jwt_required()
def reject_content(topic_id):
    user_id = int(get_jwt_identity())
    data = request.get_json()
    content_type = data.get('content_type')

    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        UPDATE content_status
        SET status = 'rejected'
        WHERE topic_id = %s AND content_type = %s
    """, (topic_id, content_type))

    if content_type == 'urdu':
        cursor.execute("""
            UPDATE topics SET urdu_paragraph_1=NULL, urdu_paragraph_2=NULL,
            urdu_paragraph_3=NULL, urdu_paragraph_4=NULL, urdu_paragraph_5=NULL
            WHERE topic_id = %s
        """, (topic_id,))
    elif content_type == 'audio_en':
        cursor.execute("UPDATE topics SET audio_en_path=NULL WHERE topic_id = %s", (topic_id,))
    elif content_type in ('animation', 'diagram'):
        cursor.execute("UPDATE topics SET visual_path=NULL WHERE topic_id = %s", (topic_id,))
    elif content_type == 'visual_narration':
        cursor.execute("UPDATE topics SET visual_narration=NULL WHERE topic_id = %s", (topic_id,))
    elif content_type == 'lecture':
        cursor.execute("DELETE FROM lecture_slides WHERE topic_id = %s", (topic_id,))
    elif content_type == 'mindmap':
        cursor.execute("UPDATE topics SET mindmap_json=NULL WHERE topic_id = %s", (topic_id,))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': f'{content_type} rejected and cleared'})