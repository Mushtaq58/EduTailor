from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from database import get_db_connection
from werkzeug.security import generate_password_hash
from datetime import datetime
import subprocess
import sys
import os
import json

admin_bp = Blueprint('admin', __name__)


def require_admin():
    """Check if current JWT user is admin. Returns (user_row, error_response)."""
    user_id = int(get_jwt_identity())
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()
    if not user or user['role'] != 'admin':
        return None, (jsonify({'error': 'Admin access required'}), 403)
    return user, None


# ─── STATS ───────────────────────────────────────────────────────────────────

@admin_bp.route('/stats', methods=['GET'])
@jwt_required()
def get_stats():
    user, err = require_admin()
    if err:
        return err

    conn = get_db_connection()
    try:
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(*) as count FROM users WHERE role = 'student'")
        total_students = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM users WHERE role = 'teacher'")
        total_teachers = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM topics")
        total_topics = cursor.fetchone()['count']

        cursor.execute("SELECT COUNT(*) as count FROM quiz_attempts")
        total_quiz_attempts = cursor.fetchone()['count']

        cursor.execute("""
            SELECT COUNT(DISTINCT user_id) as count FROM format_tracking
            WHERE session_date = CURRENT_DATE
        """)
        active_today = cursor.fetchone()['count']

        cursor.close()
        conn.close()

        return jsonify({
            'total_students': total_students,
            'total_teachers': total_teachers,
            'total_topics': total_topics,
            'total_quiz_attempts': total_quiz_attempts,
            'active_today': active_today
        })
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── LIST TEACHERS ────────────────────────────────────────────────────────────

@admin_bp.route('/teachers', methods=['GET'])
@jwt_required()
def get_teachers():
    user, err = require_admin()
    if err:
        return err

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, full_name, email, is_verified, created_at
            FROM users WHERE role = 'teacher'
            ORDER BY created_at DESC
        """)
        rows = cursor.fetchall()
        teachers = [dict(r) for r in rows]
        for t in teachers:
            if t.get('created_at'):
                t['created_at'] = t['created_at'].isoformat()
        cursor.close()
        conn.close()
        return jsonify({'teachers': teachers})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── LIST STUDENTS ────────────────────────────────────────────────────────────

@admin_bp.route('/students', methods=['GET'])
@jwt_required()
def get_students():
    user, err = require_admin()
    if err:
        return err

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("""
            SELECT id, full_name, email, is_verified, created_at
            FROM users WHERE role = 'student'
            ORDER BY created_at DESC
        """)
        rows = cursor.fetchall()
        students = [dict(r) for r in rows]
        for s in students:
            if s.get('created_at'):
                s['created_at'] = s['created_at'].isoformat()
        cursor.close()
        conn.close()
        return jsonify({'students': students})
    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── CREATE TEACHER ───────────────────────────────────────────────────────────

@admin_bp.route('/create-teacher', methods=['POST'])
@jwt_required()
def create_teacher():
    user, err = require_admin()
    if err:
        return err

    data = request.get_json()
    full_name = (data.get('full_name') or '').strip()
    email = (data.get('email') or '').strip().lower()
    password = (data.get('password') or '').strip()

    if not full_name or not email or not password:
        return jsonify({'error': 'full_name, email, and password are required'}), 400
    if len(password) < 8:
        return jsonify({'error': 'Password must be at least 8 characters'}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'error': 'Email already registered'}), 409

        password_hash = generate_password_hash(password)
        cursor.execute("""
            INSERT INTO users (email, password_hash, full_name, role, is_verified)
            VALUES (%s, %s, %s, 'teacher', TRUE)
            RETURNING id
        """, (email, password_hash, full_name))
        new_id = cursor.fetchone()['id']
        conn.commit()
        cursor.close()
        conn.close()

        return jsonify({
            'message': 'Teacher account created successfully',
            'teacher_id': new_id,
            'email': email,
            'full_name': full_name
        }), 201
    except Exception as e:
        conn.rollback()
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── DEACTIVATE USER ──────────────────────────────────────────────────────────

@admin_bp.route('/users/<int:target_id>/deactivate', methods=['PUT'])
@jwt_required()
def deactivate_user(target_id):
    user, err = require_admin()
    if err:
        return err

    if target_id == user['id']:
        return jsonify({'error': 'Cannot deactivate your own account'}), 400

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT role FROM users WHERE id = %s", (target_id,))
        row = cursor.fetchone()
        if not row:
            cursor.close()
            conn.close()
            return jsonify({'error': 'User not found'}), 404
        if row['role'] == 'admin':
            cursor.close()
            conn.close()
            return jsonify({'error': 'Cannot deactivate admin accounts'}), 400

        cursor.execute("UPDATE users SET is_verified = FALSE WHERE id = %s", (target_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'User deactivated successfully'})
    except Exception as e:
        conn.rollback()
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── ACTIVATE USER ────────────────────────────────────────────────────────────

@admin_bp.route('/users/<int:target_id>/activate', methods=['PUT'])
@jwt_required()
def activate_user(target_id):
    user, err = require_admin()
    if err:
        return err

    conn = get_db_connection()
    try:
        cursor = conn.cursor()
        cursor.execute("SELECT id FROM users WHERE id = %s", (target_id,))
        if not cursor.fetchone():
            cursor.close()
            conn.close()
            return jsonify({'error': 'User not found'}), 404

        cursor.execute("UPDATE users SET is_verified = TRUE WHERE id = %s", (target_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'message': 'User activated successfully'})
    except Exception as e:
        conn.rollback()
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── RAG STATUS ───────────────────────────────────────────────────────────────

@admin_bp.route('/rag-status', methods=['GET'])
@jwt_required()
def rag_status():
    user, err = require_admin()
    if err:
        return err

    try:
        base_dir = os.path.dirname(os.path.abspath(__file__)).replace('routes', '')
        metadata_path = os.path.join(base_dir, 'backend', 'data', 'metadata.json')
        faiss_path = os.path.join(base_dir, 'backend', 'data', 'faiss_index.bin')

        chunk_count = None
        last_rebuilt = None

        if os.path.exists(metadata_path):
            with open(metadata_path, 'r', encoding='utf-8') as f:
                metadata = json.load(f)
            chunk_count = len(metadata)
            mtime = os.path.getmtime(metadata_path)
            last_rebuilt = datetime.fromtimestamp(mtime).isoformat()

        faiss_exists = os.path.exists(faiss_path)

        return jsonify({
            'chunk_count': chunk_count,
            'last_rebuilt': last_rebuilt,
            'faiss_exists': faiss_exists,
            'status': 'ready' if faiss_exists and chunk_count else 'not_built'
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500


# ─── REBUILD RAG ──────────────────────────────────────────────────────────────

@admin_bp.route('/rebuild-rag', methods=['POST'])
@jwt_required()
def rebuild_rag():
    user, err = require_admin()
    if err:
        return err

    try:
        base_dir = os.path.dirname(os.path.abspath(__file__)).replace('routes', '')

        # Try root-level first, then backend/scripts/
        script_path = os.path.join(base_dir, 'scripts', 'build_rag_index.py')
        if not os.path.exists(script_path):
            script_path = os.path.join(base_dir, 'scripts', 'build_rag_index.py')

        if not os.path.exists(script_path):
            return jsonify({'error': 'build_rag_index.py not found'}), 500

        result = subprocess.run(
            [sys.executable, script_path],
            capture_output=True,
            text=True,
            timeout=120,
            cwd=base_dir
        )

        if result.returncode == 0:
            metadata_path = os.path.join(base_dir, 'backend', 'data', 'metadata.json')
            chunk_count = None
            if os.path.exists(metadata_path):
                with open(metadata_path, 'r', encoding='utf-8') as f:
                    metadata = json.load(f)
                chunk_count = len(metadata)

            return jsonify({
                'message': 'RAG index rebuilt successfully',
                'chunk_count': chunk_count,
                'rebuilt_at': datetime.utcnow().isoformat()
            })
        else:
            return jsonify({
                'error': 'RAG rebuild failed',
                'details': result.stderr[-500:] if result.stderr else 'Unknown error'
            }), 500

    except subprocess.TimeoutExpired:
        return jsonify({'error': 'RAG rebuild timed out (>120s)'}), 500
    except Exception as e:
        return jsonify({'error': str(e)}), 500