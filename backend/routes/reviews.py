from flask import Blueprint, jsonify, request
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection

reviews_bp = Blueprint('reviews', __name__)


@reviews_bp.route('/submit', methods=['POST'])
@jwt_required()
def submit_review():
    user_id = int(get_jwt_identity())
    data = request.get_json()

    topic_id = data.get('topic_id')
    rating = data.get('rating') or data.get('content_rating')
    comment = data.get('comment', '').strip()

    if not topic_id or not rating:
        return jsonify({'error': 'topic_id and rating are required'}), 400

    if not (1 <= int(rating) <= 5):
        return jsonify({'error': 'Rating must be between 1 and 5'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id FROM feedback
        WHERE user_id = %s AND topic_id = %s
    """, (user_id, topic_id))
    existing = cursor.fetchone()

    if existing:
        cursor.execute("""
            UPDATE feedback
            SET rating = %s, feedback_text = %s, submitted_at = NOW()
            WHERE user_id = %s AND topic_id = %s
        """, (rating, comment, user_id, topic_id))
        message = 'Review updated successfully'
    else:
        cursor.execute("""
            INSERT INTO feedback (user_id, topic_id, rating, feedback_text)
            VALUES (%s, %s, %s, %s)
        """, (user_id, topic_id, rating, comment))
        message = 'Review submitted successfully'

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': message})


@reviews_bp.route('/my-review/<topic_id>', methods=['GET'])
@jwt_required()
def get_my_review(topic_id):
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT rating, feedback_text, submitted_at
        FROM feedback
        WHERE user_id = %s AND topic_id = %s
    """, (user_id, topic_id))
    review = cursor.fetchone()

    cursor.close()
    conn.close()

    if not review:
        return jsonify({'review': None})

    return jsonify({
        'review': {
            'rating': review['rating'],
            'content_rating': review['rating'],
            'comment': review['feedback_text'],
            'submitted_at': review['submitted_at'].isoformat() if review['submitted_at'] else None,
        }
    })


@reviews_bp.route('/teacher/all', methods=['GET'])
@jwt_required()
def get_all_reviews():
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
            t.topic_id,
            t.topic_name,
            COUNT(f.id) as review_count,
            ROUND(AVG(f.rating), 1) as avg_rating
        FROM topics t
        LEFT JOIN feedback f ON f.topic_id = t.topic_id
        GROUP BY t.topic_id, t.topic_name
        ORDER BY t.topic_id
    """)
    topic_summaries = cursor.fetchall()

    cursor.execute("""
        SELECT
            f.id,
            f.topic_id,
            t.topic_name,
            f.rating,
            f.feedback_text as comment,
            f.submitted_at
        FROM feedback f
        JOIN topics t ON t.topic_id = f.topic_id
        ORDER BY f.submitted_at DESC
    """)
    all_reviews = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify({
        'topic_summaries': [dict(r) for r in topic_summaries],
        'reviews': [
            {
                'id': r['id'],
                'topic_id': r['topic_id'],
                'topic_name': r['topic_name'],
                'rating': r['rating'],
                'content_rating': r['rating'],
                'comment': r['comment'],
                'submitted_at': r['submitted_at'].isoformat() if r['submitted_at'] else None,
            }
            for r in all_reviews
        ]
    })


@reviews_bp.route('/teacher/respond/<int:review_id>', methods=['POST'])
@jwt_required()
def respond_to_review(review_id):
    # teacher_response column doesn't exist in current schema
    # This endpoint is kept for API compatibility but does nothing harmful
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if not user or user['role'] != 'teacher':
        return jsonify({'error': 'Teacher access required'}), 403

    return jsonify({'message': 'Response noted'})