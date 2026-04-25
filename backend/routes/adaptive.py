from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection

adaptive_bp = Blueprint('adaptive', __name__)


@adaptive_bp.route('/track-format', methods=['POST'])
@jwt_required()
def track_format():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    topic_id = data.get('topic_id')
    format_name = data.get('format')
    time_spent = data.get('time_spent_seconds', 0)

    if not topic_id or not format_name:
        return jsonify({'error': 'topic_id and format are required'}), 400

    valid_formats = ['english', 'urdu', 'audio_en', 'audio_ur', 'visual', 'lecture']
    if format_name not in valid_formats:
        return jsonify({'error': f'Invalid format. Must be one of {valid_formats}'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, time_spent_seconds FROM format_tracking
        WHERE user_id = %s AND topic_id = %s AND format = %s
        AND DATE(session_date) = CURRENT_DATE
    """, (user_id, topic_id, format_name))
    existing = cursor.fetchone()

    if existing:
        cursor.execute("""
            UPDATE format_tracking
            SET time_spent_seconds = time_spent_seconds + %s
            WHERE id = %s
        """, (time_spent, existing['id']))
    else:
        cursor.execute("""
            INSERT INTO format_tracking (user_id, topic_id, format, time_spent_seconds)
            VALUES (%s, %s, %s, %s)
        """, (user_id, topic_id, format_name, time_spent))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Format tracked successfully'})


@adaptive_bp.route('/vark-scores', methods=['GET'])
@jwt_required()
def get_vark_scores():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT format, SUM(time_spent_seconds) as total_time
        FROM format_tracking
        WHERE user_id = %s
        GROUP BY format
    """, (user_id,))
    time_data = {row['format']: row['total_time'] for row in cursor.fetchall()}

    cursor.execute("""
        SELECT qa.format_used, AVG(qa.total_score) as avg_score, COUNT(*) as attempts
        FROM quiz_attempts qa
        WHERE qa.user_id = %s AND qa.format_used IS NOT NULL
        GROUP BY qa.format_used
    """, (user_id,))
    score_data = {row['format_used']: {
        'avg_score': float(row['avg_score']),
        'attempts': row['attempts']
    } for row in cursor.fetchall()}

    vark_map = {
        'english':  'reading',
        'urdu':     'reading',
        'audio_en': 'auditory',
        'audio_ur': 'auditory',
        'visual':   'visual',
        'lecture':  'auditory',
    }

    vark_scores = {'visual': 0, 'auditory': 0, 'reading': 0}
    format_scores = {}

    for fmt, category in vark_map.items():
        time = time_data.get(fmt, 0)
        score_info = score_data.get(fmt, {})
        avg_score = score_info.get('avg_score', 50)
        combined = (time * 0.7) + (avg_score * 0.3 * 10)
        vark_scores[category] += combined
        format_scores[fmt] = {
            'time_spent_seconds': time,
            'avg_quiz_score': round(avg_score, 1),
            'combined_score': round(combined, 1),
        }

    format_combined = {
        'english':  format_scores.get('english',  {}).get('combined_score', 0),
        'urdu':     format_scores.get('urdu',     {}).get('combined_score', 0),
        'audio_en': format_scores.get('audio_en', {}).get('combined_score', 0),
        'audio_ur': format_scores.get('audio_ur', {}).get('combined_score', 0),
        'visual':   format_scores.get('visual',   {}).get('combined_score', 0),
        'lecture':  format_scores.get('lecture',  {}).get('combined_score', 0),
    }
    recommended = max(format_combined, key=format_combined.get) if any(format_combined.values()) else 'english'

    cursor.execute("""
        INSERT INTO user_preferences (user_id, recommended_format, updated_at)
        VALUES (%s, %s, NOW())
        ON CONFLICT (user_id)
        DO UPDATE SET recommended_format = %s, updated_at = NOW()
    """, (user_id, recommended, recommended))
    conn.commit()

    cursor.close()
    conn.close()

    return jsonify({
        'vark_scores': {
            'visual':   round(vark_scores['visual'], 1),
            'auditory': round(vark_scores['auditory'], 1),
            'reading':  round(vark_scores['reading'], 1),
        },
        'format_scores': format_scores,
        'recommended_format': recommended,
        'time_data': time_data,
    })


@adaptive_bp.route('/recommendation', methods=['GET'])
@jwt_required()
def get_recommendation():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT recommended_format FROM user_preferences
        WHERE user_id = %s
    """, (user_id,))
    pref = cursor.fetchone()

    cursor.close()
    conn.close()

    recommended = pref['recommended_format'] if pref else 'english'
    return jsonify({'recommended_format': recommended})


@adaptive_bp.route('/update-quiz-format', methods=['POST'])
@jwt_required()
def update_quiz_format():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    topic_id = data.get('topic_id')
    quiz_score = data.get('quiz_score')
    format_used = data.get('format_used')

    if not all([topic_id, quiz_score is not None, format_used]):
        return jsonify({'error': 'topic_id, quiz_score, format_used required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        UPDATE format_tracking
        SET quiz_score_after = %s
        WHERE user_id = %s AND topic_id = %s AND format = %s
        AND id = (
            SELECT id FROM format_tracking
            WHERE user_id = %s AND topic_id = %s AND format = %s
            ORDER BY session_date DESC LIMIT 1
        )
    """, (quiz_score, user_id, topic_id, format_used,
          user_id, topic_id, format_used))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Quiz format score updated'})


@adaptive_bp.route('/format-analytics', methods=['GET'])
@jwt_required()
def get_format_analytics():
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
        SELECT format, SUM(time_spent_seconds) as total_time,
               COUNT(DISTINCT user_id) as student_count
        FROM format_tracking
        GROUP BY format
        ORDER BY total_time DESC
    """)
    format_popularity = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT ft.format,
               AVG(ft.quiz_score_after) as avg_score,
               COUNT(ft.quiz_score_after) as scored_count
        FROM format_tracking ft
        WHERE ft.quiz_score_after IS NOT NULL
        GROUP BY ft.format
        ORDER BY avg_score DESC
    """)
    format_performance = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT u.full_name, u.email, up.recommended_format
        FROM users u
        LEFT JOIN user_preferences up ON up.user_id = u.id
        WHERE u.role = 'student'
        ORDER BY u.full_name
    """)
    student_preferences = [dict(row) for row in cursor.fetchall()]

    cursor.close()
    conn.close()

    return jsonify({
        'format_popularity': format_popularity,
        'format_performance': format_performance,
        'student_preferences': student_preferences,
    })


@adaptive_bp.route('/student-analytics', methods=['GET'])
@jwt_required()
def get_student_analytics():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT visual_score, auditory_score, reading_score,
               kinesthetic_score, recommended_format
        FROM vark_assessments
        WHERE user_id = %s
        ORDER BY assessed_at DESC LIMIT 1
    """, (user_id,))
    vark = cursor.fetchone()

    cursor.execute("""
        SELECT recommended_format FROM user_preferences WHERE user_id = %s
    """, (user_id,))
    pref = cursor.fetchone()

    cursor.execute("""
        SELECT qa.topic_id, t.topic_name, qa.total_score,
               qa.mcq_score, qa.subjective_score, qa.attempted_at
        FROM quiz_attempts qa
        JOIN topics t ON t.topic_id = qa.topic_id
        WHERE qa.user_id = %s
        ORDER BY qa.attempted_at DESC
    """, (user_id,))
    quiz_history = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT qa.topic_id, t.topic_name,
               MAX(qa.total_score) as best_score,
               COUNT(*) as attempts
        FROM quiz_attempts qa
        JOIN topics t ON t.topic_id = qa.topic_id
        WHERE qa.user_id = %s
        GROUP BY qa.topic_id, t.topic_name
        ORDER BY qa.topic_id
    """, (user_id,))
    topic_scores = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT sp.topic_id, t.topic_name, sp.status, sp.best_score
        FROM student_progress sp
        JOIN topics t ON t.topic_id = sp.topic_id
        WHERE sp.user_id = %s
        ORDER BY sp.topic_id
    """, (user_id,))
    progress = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT format, SUM(time_spent_seconds) as total_seconds
        FROM format_tracking
        WHERE user_id = %s
        GROUP BY format
        ORDER BY total_seconds DESC
    """, (user_id,))
    format_time = [dict(row) for row in cursor.fetchall()]

    cursor.close()
    conn.close()

    return jsonify({
        'vark': dict(vark) if vark else None,
        'recommended_format': pref['recommended_format'] if pref else 'english',
        'quiz_history': quiz_history,
        'topic_scores': topic_scores,
        'progress': progress,
        'format_time': format_time,
    })


@adaptive_bp.route('/teacher-analytics', methods=['GET'])
@jwt_required()
def get_teacher_analytics():
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
        SELECT DATE_TRUNC('week', attempted_at) as week,
               ROUND(AVG(total_score), 1) as avg_score,
               COUNT(*) as attempts
        FROM quiz_attempts
        GROUP BY week
        ORDER BY week ASC
    """)
    score_over_time = []
    for row in cursor.fetchall():
        score_over_time.append({
            'week': row['week'].strftime('%Y-%m-%d'),
            'avg_score': float(row['avg_score']),
            'attempts': row['attempts'],
        })

    cursor.execute("""
        SELECT qa.topic_id, t.topic_name,
               ROUND(AVG(qa.total_score), 1) as avg_score,
               MAX(qa.total_score) as max_score,
               MIN(qa.total_score) as min_score,
               COUNT(*) as total_attempts
        FROM quiz_attempts qa
        JOIN topics t ON t.topic_id = qa.topic_id
        GROUP BY qa.topic_id, t.topic_name
        ORDER BY qa.topic_id
    """)
    topic_performance = []
    for row in cursor.fetchall():
        topic_performance.append({
            'topic_id': row['topic_id'],
            'topic_name': row['topic_name'],
            'avg_score': float(row['avg_score']),
            'max_score': row['max_score'],
            'min_score': row['min_score'],
            'total_attempts': row['total_attempts'],
        })

    cursor.execute("""
        SELECT format_used,
               ROUND(AVG(total_score), 1) as avg_score,
               COUNT(*) as attempts
        FROM quiz_attempts
        WHERE format_used IS NOT NULL
        GROUP BY format_used
        ORDER BY avg_score DESC
    """)
    format_performance = []
    for row in cursor.fetchall():
        format_performance.append({
            'format': row['format_used'],
            'avg_score': float(row['avg_score']),
            'attempts': row['attempts'],
        })

    cursor.execute("""
        SELECT format,
               SUM(time_spent_seconds) as total_seconds,
               COUNT(DISTINCT user_id) as student_count
        FROM format_tracking
        GROUP BY format
        ORDER BY total_seconds DESC
    """)
    format_usage = [dict(row) for row in cursor.fetchall()]

    cursor.execute("""
        SELECT
            COUNT(DISTINCT CASE WHEN sp.status = 'completed' THEN sp.user_id END) as completed_students,
            COUNT(DISTINCT CASE WHEN sp.status = 'in_progress' THEN sp.user_id END) as in_progress_students,
            COUNT(DISTINCT u.id) as total_students
        FROM users u
        LEFT JOIN student_progress sp ON sp.user_id = u.id
        WHERE u.role = 'student'
    """)
    progress_overview = dict(cursor.fetchone())

    cursor.execute("""
        SELECT u.id, u.full_name, u.email,
               ROUND(AVG(qa.total_score), 1) as avg_score,
               COUNT(qa.id) as attempts
        FROM users u
        JOIN quiz_attempts qa ON qa.user_id = u.id
        WHERE u.role = 'student'
        GROUP BY u.id, u.full_name, u.email
        HAVING AVG(qa.total_score) < 50
        ORDER BY avg_score ASC
    """)
    at_risk = []
    for row in cursor.fetchall():
        at_risk.append({
            'id': row['id'],
            'name': row['full_name'],
            'email': row['email'],
            'avg_score': float(row['avg_score']),
            'attempts': row['attempts'],
        })

    cursor.execute("""
        SELECT u.full_name, u.email,
               va.visual_score, va.auditory_score,
               va.reading_score, va.recommended_format
        FROM users u
        JOIN vark_assessments va ON va.user_id = u.id
        WHERE u.role = 'student'
        ORDER BY u.full_name
    """)
    vark_profiles = []
    for row in cursor.fetchall():
        vark_profiles.append({
            'name': row['full_name'],
            'email': row['email'],
            'visual_score': row['visual_score'],
            'auditory_score': row['auditory_score'],
            'reading_score': row['reading_score'],
            'recommended_format': row['recommended_format'],
        })

    cursor.close()
    conn.close()

    return jsonify({
        'score_over_time': score_over_time,
        'topic_performance': topic_performance,
        'format_performance': format_performance,
        'format_usage': format_usage,
        'progress_overview': progress_overview,
        'at_risk': at_risk,
        'vark_profiles': vark_profiles,
    })