from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection

teacher_bp = Blueprint('teacher', __name__)


def require_teacher(cursor, user_id):
    cursor.execute("SELECT role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    return user and user['role'] == 'teacher'


@teacher_bp.route('/students', methods=['GET'])
@jwt_required()
def get_students():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("SELECT id, email, full_name FROM users WHERE role = 'student'")
    students = cursor.fetchall()

    result = []
    for s in students:
        cursor.execute("""
            SELECT total_score FROM quiz_attempts WHERE user_id = %s
        """, (s['id'],))
        attempts = cursor.fetchall()

        avg_score = None
        if attempts:
            avg_score = round(
                sum(a['total_score'] for a in attempts) / len(attempts), 1
            )

        cursor.execute("""
            SELECT COUNT(*) as cnt FROM student_progress
            WHERE user_id = %s AND status = 'completed'
        """, (s['id'],))
        completed = cursor.fetchone()['cnt']

        result.append({
            'id': s['id'],
            'name': s['full_name'],
            'email': s['email'],
            'avg_score': avg_score,
            'quiz_attempts': len(attempts),
            'topics_completed': completed,
        })

    cursor.close()
    conn.close()
    return jsonify({'students': result})


@teacher_bp.route('/topics', methods=['GET'])
@jwt_required()
def get_topics():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("""
        SELECT COUNT(*) as cnt FROM users WHERE role = 'student'
    """)
    total_students = cursor.fetchone()['cnt']

    cursor.execute("""
        SELECT topic_id, topic_name FROM topics ORDER BY topic_id
    """)
    topics = cursor.fetchall()

    result = []
    for t in topics:
        cursor.execute("""
            SELECT COUNT(*) as cnt FROM student_progress
            WHERE topic_id = %s AND status = 'completed'
        """, (t['topic_id'],))
        completed = cursor.fetchone()['cnt']

        completion_rate = round(
            (completed / total_students * 100)
        ) if total_students > 0 else 0

        result.append({
            'id': t['topic_id'],
            'title': t['topic_name'],
            'completion_rate': completion_rate,
            'most_common_status': (
                'completed' if completion_rate >= 70
                else 'in_progress' if completion_rate > 0
                else 'not_started'
            ),
        })

    cursor.close()
    conn.close()
    return jsonify({'topics': result})


@teacher_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_stats():
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    cursor.execute("SELECT COUNT(*) as cnt FROM users WHERE role = 'student'")
    total_students = cursor.fetchone()['cnt']

    cursor.execute("SELECT COUNT(*) as cnt FROM quiz_attempts")
    total_attempts = cursor.fetchone()['cnt']

    cursor.execute("SELECT AVG(total_score) as avg FROM quiz_attempts")
    avg_row = cursor.fetchone()
    avg_score = round(float(avg_row['avg']), 1) if avg_row['avg'] else None

    cursor.close()
    conn.close()

    return jsonify({
        'total_students': total_students,
        'total_attempts': total_attempts,
        'avg_score': avg_score,
    })


@teacher_bp.route('/analytics', methods=['GET'])
@jwt_required()
def get_analytics():
    user_id = int(get_jwt_identity())
    student_id = request.args.get('student_id')

    conn = get_db_connection()
    cursor = conn.cursor()

    if not require_teacher(cursor, user_id):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Teacher access required'}), 403

    if not student_id:
        cursor.close()
        conn.close()
        return jsonify({'attempts': [], 'topic_scores': [], 'topics_completed': 0})

    cursor.execute(
        "SELECT id, email, full_name FROM users WHERE id = %s", (student_id,)
    )
    student = cursor.fetchone()
    if not student:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Student not found'}), 404

    cursor.execute("""
        SELECT qa.id, qa.topic_id, qa.total_score as score,
               qa.mcq_score, qa.subjective_score,
               qa.mcq_responses, qa.subjective_responses,
               qa.attempted_at as created_at,
               t.topic_name as topic_title
        FROM quiz_attempts qa
        JOIN topics t ON t.topic_id = qa.topic_id
        WHERE qa.user_id = %s
        ORDER BY qa.attempted_at DESC
    """, (student_id,))
    attempts = cursor.fetchall()

    cursor.execute("""
        SELECT COUNT(*) as cnt FROM student_progress
        WHERE user_id = %s AND status = 'completed'
    """, (student_id,))
    topics_completed = cursor.fetchone()['cnt']

    scores = [a['score'] for a in attempts]
    avg_score = round(sum(scores) / len(scores), 1) if scores else None
    pass_rate = round(
        sum(1 for s in scores if s >= 70) / len(scores) * 100, 1
    ) if scores else None

    cursor.execute("""
        SELECT t.topic_id, t.topic_name as title,
               AVG(qa.total_score) as avg_score
        FROM quiz_attempts qa
        JOIN topics t ON t.topic_id = qa.topic_id
        WHERE qa.user_id = %s
        GROUP BY t.topic_id, t.topic_name
    """, (student_id,))
    topic_scores = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({
        'student': {
            'id': student['id'],
            'name': student['full_name'],
            'email': student['email'],
        },
        'attempts': [
            {
                'id': a['id'],
                'topic_id': a['topic_id'],
                'topic_title': a['topic_title'],
                'score': a['score'],
                'mcq_score': a['mcq_score'],
                'subjective_score': a['subjective_score'],
                'question_results': a['mcq_responses'] or {},
                'created_at': a['created_at'].isoformat(),
            }
            for a in attempts
        ],
        'topics_completed': topics_completed,
        'avg_score': avg_score,
        'pass_rate': pass_rate,
        'topic_scores': [
            {
                'topic_id': r['topic_id'],
                'title': r['title'],
                'avg_score': round(float(r['avg_score']), 1),
            }
            for r in topic_scores
        ],
    })