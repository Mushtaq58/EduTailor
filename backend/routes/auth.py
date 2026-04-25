from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from database import get_db_connection
from models.user import User
import random
import string
import smtplib
import os
from werkzeug.security import generate_password_hash, check_password_hash
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
import psycopg2.extras
from werkzeug.utils import secure_filename
from werkzeug.security import generate_password_hash

auth_bp = Blueprint('auth', __name__)

GMAIL_ADDRESS = os.getenv('GMAIL_ADDRESS')
GMAIL_APP_PASSWORD = os.getenv('GMAIL_APP_PASSWORD')
PROFILE_PICS_DIR = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'media', 'profiles')
ALLOWED_EXTENSIONS = {'png', 'jpg', 'jpeg'}

os.makedirs(PROFILE_PICS_DIR, exist_ok=True)


def generate_otp():
    return ''.join(random.choices(string.digits, k=6))


def send_otp_email(to_email, otp, purpose='verification'):
    try:
        msg = MIMEMultipart('alternative')
        msg['From'] = GMAIL_ADDRESS
        msg['To'] = to_email

        if purpose == 'verification':
            msg['Subject'] = 'EduTailor — Verify Your Email'
            html = f"""
            <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; background: #0f172a; color: #ffffff; border-radius: 12px; padding: 40px;">
                <div style="text-align: center; margin-bottom: 32px;">
                    <div style="background: #06b6d4; width: 48px; height: 48px; border-radius: 12px; display: inline-flex; align-items: center; justify-content: center; font-size: 24px;">🎓</div>
                    <h1 style="color: #ffffff; font-size: 24px; margin: 16px 0 4px;">EduTailor</h1>
                    <p style="color: #94a3b8; font-size: 14px;">Verify your email address</p>
                </div>
                <p style="color: #cbd5e1; font-size: 15px; line-height: 1.6;">Your verification code is:</p>
                <div style="background: #1e293b; border: 1px solid #334155; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
                    <span style="font-size: 40px; font-weight: bold; letter-spacing: 12px; color: #06b6d4;">{otp}</span>
                </div>
                <p style="color: #64748b; font-size: 13px; text-align: center;">This code expires in <strong style="color: #94a3b8;">10 minutes</strong>. Do not share it with anyone.</p>
                <hr style="border: none; border-top: 1px solid #1e293b; margin: 32px 0;">
                <p style="color: #475569; font-size: 12px; text-align: center;">COMSATS University Islamabad — FYP 2026</p>
            </div>
            """
        else:
            msg['Subject'] = 'EduTailor — Password Reset Code'
            html = f"""
            <div style="font-family: Arial, sans-serif; max-width: 480px; margin: 0 auto; background: #0f172a; color: #ffffff; border-radius: 12px; padding: 40px;">
                <div style="text-align: center; margin-bottom: 32px;">
                    <div style="background: #06b6d4; width: 48px; height: 48px; border-radius: 12px; display: inline-flex; align-items: center; justify-content: center; font-size: 24px;">🎓</div>
                    <h1 style="color: #ffffff; font-size: 24px; margin: 16px 0 4px;">EduTailor</h1>
                    <p style="color: #94a3b8; font-size: 14px;">Reset your password</p>
                </div>
                <p style="color: #cbd5e1; font-size: 15px; line-height: 1.6;">Your password reset code is:</p>
                <div style="background: #1e293b; border: 1px solid #334155; border-radius: 12px; padding: 24px; text-align: center; margin: 24px 0;">
                    <span style="font-size: 40px; font-weight: bold; letter-spacing: 12px; color: #06b6d4;">{otp}</span>
                </div>
                <p style="color: #64748b; font-size: 13px; text-align: center;">This code expires in <strong style="color: #94a3b8;">10 minutes</strong>. If you did not request this, ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #1e293b; margin: 32px 0;">
                <p style="color: #475569; font-size: 12px; text-align: center;">COMSATS University Islamabad — FYP 2026</p>
            </div>
            """

        msg.attach(MIMEText(html, 'html'))
        with smtplib.SMTP_SSL('smtp.gmail.com', 465) as server:
            server.login(GMAIL_ADDRESS, GMAIL_APP_PASSWORD)
            server.sendmail(GMAIL_ADDRESS, to_email, msg.as_string())
        return True
    except Exception as e:
        print(f"Email send error: {e}")
        return False


def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


# ─── REGISTER ───────────────────────────────────────────────────────────────

@auth_bp.route('/register', methods=['POST'])
def register():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')
    full_name = data.get('full_name')
    role = 'student'

    if not email or not password or not full_name:
        return jsonify({'error': 'Missing required fields'}), 400

    conn = get_db_connection()

    existing_user = User.find_by_email(conn, email)
    if existing_user:
        conn.close()
        return jsonify({'error': 'Email already registered'}), 400

    try:
        user = User.create(conn, email, password, full_name, role)

        otp = generate_otp()
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO otp_verifications (user_id, otp_code, purpose, expires_at, created_at)
            VALUES (%s, %s, 'email_verification', %s, NOW())
        """, (user['id'], otp, datetime.utcnow() + timedelta(minutes=10)))
        conn.commit()
        cursor.close()
        conn.close()

        send_otp_email(email, otp, purpose='verification')

        return jsonify({
            'message': 'Registration successful. Please verify your email.',
            'user_id': user['id'],
            'email': email
        }), 201

    except Exception as e:
        conn.close()
        return jsonify({'error': str(e)}), 500


# ─── VERIFY OTP ─────────────────────────────────────────────────────────────

@auth_bp.route('/verify-otp', methods=['POST'])
def verify_otp():
    data = request.get_json()
    user_id = data.get('user_id')
    otp_code = data.get('otp_code')
    purpose = data.get('purpose', 'email_verification')

    if not user_id or not otp_code:
        return jsonify({'error': 'Missing required fields'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, otp_code, expires_at, used
        FROM otp_verifications
        WHERE user_id = %s AND purpose = %s AND used = FALSE
        ORDER BY created_at DESC LIMIT 1
    """, (user_id, purpose))
    record = cursor.fetchone()

    if not record:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Invalid or expired OTP'}), 400

    if record['used']:
        cursor.close()
        conn.close()
        return jsonify({'error': 'OTP already used'}), 400

    if datetime.utcnow() > record['expires_at'].replace(tzinfo=None):
        cursor.close()
        conn.close()
        return jsonify({'error': 'OTP has expired'}), 400

    if record['otp_code'] != otp_code:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Incorrect OTP'}), 400

    cursor.execute("UPDATE otp_verifications SET used = TRUE WHERE id = %s", (record['id'],))

    if purpose == 'email_verification':
        cursor.execute("UPDATE users SET is_verified = TRUE WHERE id = %s", (user_id,))

    conn.commit()

    cursor.execute("SELECT id, email, full_name, role FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    access_token = create_access_token(identity=str(user['id']))

    return jsonify({
        'message': 'OTP verified successfully',
        'user': dict(user),
        'access_token': access_token
    }), 200


# ─── RESEND OTP ─────────────────────────────────────────────────────────────

@auth_bp.route('/resend-otp', methods=['POST'])
def resend_otp():
    data = request.get_json()
    user_id = data.get('user_id')
    purpose = data.get('purpose', 'email_verification')

    if not user_id:
        return jsonify({'error': 'Missing user_id'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("SELECT id, email, is_verified FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    if not user:
        cursor.close()
        conn.close()
        return jsonify({'error': 'User not found'}), 404

    if purpose == 'email_verification' and user['is_verified']:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Email already verified'}), 400

    cursor.execute("""
        UPDATE otp_verifications SET used = TRUE
        WHERE user_id = %s AND purpose = %s AND used = FALSE
    """, (user_id, purpose))

    otp = generate_otp()
    cursor.execute("""
        INSERT INTO otp_verifications (user_id, otp_code, purpose, expires_at, created_at)
        VALUES (%s, %s, %s, %s, NOW())
    """, (user_id, otp, purpose, datetime.utcnow() + timedelta(minutes=10)))

    conn.commit()
    cursor.close()
    conn.close()

    send_otp_email(user['email'], otp, purpose='verification' if purpose == 'email_verification' else 'reset')

    return jsonify({'message': 'OTP resent successfully'}), 200


# ─── FORGOT PASSWORD ─────────────────────────────────────────────────────────

@auth_bp.route('/forgot-password', methods=['POST'])
def forgot_password():
    data = request.get_json()
    email = data.get('email')

    if not email:
        return jsonify({'error': 'Email is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT id, email FROM users WHERE email = %s", (email,))
    user = cursor.fetchone()

    if not user:
        cursor.close()
        conn.close()
        return jsonify({'message': 'If this email exists, a reset code has been sent.', 'user_id': None}), 200

    cursor.execute("""
        UPDATE otp_verifications SET used = TRUE
        WHERE user_id = %s AND purpose = 'password_reset' AND used = FALSE
    """, (user['id'],))

    otp = generate_otp()
    cursor.execute("""
        INSERT INTO otp_verifications (user_id, otp_code, purpose, expires_at, created_at)
        VALUES (%s, %s, 'password_reset', %s, NOW())
    """, (user['id'], otp, datetime.utcnow() + timedelta(minutes=10)))

    conn.commit()
    cursor.close()
    conn.close()

    send_otp_email(email, otp, purpose='reset')

    return jsonify({
        'message': 'If this email exists, a reset code has been sent.',
        'user_id': user['id']
    }), 200


# ─── RESET PASSWORD ──────────────────────────────────────────────────────────

@auth_bp.route('/reset-password', methods=['POST'])
def reset_password():
    data = request.get_json()
    user_id = data.get('user_id')
    otp_code = data.get('otp_code')
    new_password = data.get('new_password')

    if not user_id or not otp_code or not new_password:
        return jsonify({'error': 'Missing required fields'}), 400

    if len(new_password) < 8:
        return jsonify({'error': 'Password must be at least 8 characters'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()

    cursor.execute("""
        SELECT id, otp_code, expires_at, used
        FROM otp_verifications
        WHERE user_id = %s AND purpose = 'password_reset' AND used = FALSE
        ORDER BY created_at DESC LIMIT 1
    """, (user_id,))
    record = cursor.fetchone()

    if not record or record['otp_code'] != otp_code:
        cursor.close()
        conn.close()
        return jsonify({'error': 'Invalid or expired OTP'}), 400

    if datetime.utcnow() > record['expires_at'].replace(tzinfo=None):
        cursor.close()
        conn.close()
        return jsonify({'error': 'OTP has expired'}), 400

    password_hash = generate_password_hash(new_password)

    cursor.execute("UPDATE users SET password_hash = %s WHERE id = %s", (password_hash, user_id))
    cursor.execute("UPDATE otp_verifications SET used = TRUE WHERE id = %s", (record['id'],))

    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Password reset successfully'}), 200


# ─── LOGIN ───────────────────────────────────────────────────────────────────

@auth_bp.route('/login', methods=['POST'])
def login():
    data = request.get_json()

    email = data.get('email')
    password = data.get('password')

    if not email or not password:
        return jsonify({'error': 'Missing email or password'}), 400

    conn = get_db_connection()
    user = User.find_by_email(conn, email)

    if not user or not User.verify_password(user['password_hash'], password):
        conn.close()
        return jsonify({'error': 'Invalid credentials'}), 401

    if not user.get('is_verified'):
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE otp_verifications SET used = TRUE
            WHERE user_id = %s AND purpose = 'email_verification' AND used = FALSE
        """, (user['id'],))
        otp = generate_otp()
        cursor.execute("""
            INSERT INTO otp_verifications (user_id, otp_code, purpose, expires_at, created_at)
            VALUES (%s, %s, 'email_verification', %s, NOW())
        """, (user['id'], otp, datetime.utcnow() + timedelta(minutes=10)))
        conn.commit()
        cursor.close()
        conn.close()
        send_otp_email(email, otp, purpose='verification')
        return jsonify({
            'error': 'Email not verified. A new verification code has been sent to your email.',
            'unverified': True,
            'user_id': user['id'],
            'email': email
        }), 403

    User.update_last_login(conn, user['id'])
    conn.close()

    access_token = create_access_token(identity=str(user['id']))

    return jsonify({
        'message': 'Login successful',
        'user': { 
            'id': user['id'],
            'email': user['email'],
            'full_name': user['full_name'],
            'role': user['role'],
            'profile_picture_url': user['profile_picture_url'],
            'is_verified': user['is_verified']
        },
        'access_token': access_token
    }), 200


# ─── GET CURRENT USER ────────────────────────────────────────────────────────

@auth_bp.route('/me', methods=['GET'])
@jwt_required()
def get_current_user():
    user_id = int(get_jwt_identity())

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        SELECT id, email, full_name, role, profile_picture_url
        FROM users WHERE id = %s
    """, (user_id,))
    user = cursor.fetchone()
    cursor.close()
    conn.close()

    if not user:
        return jsonify({'error': 'User not found'}), 404

    return jsonify({'user': dict(user)}), 200


# ─── UPDATE PROFILE ──────────────────────────────────────────────────────────

@auth_bp.route('/update-profile', methods=['PUT'])
@jwt_required()
def update_profile():
    user_id = int(get_jwt_identity())
    data = request.get_json()
    full_name = data.get('full_name', '').strip()

    if not full_name:
        return jsonify({'error': 'Full name is required'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE users SET full_name = %s WHERE id = %s
        RETURNING id, email, full_name, role, profile_picture_url
    """, (full_name, user_id))
    user = cursor.fetchone()
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Profile updated', 'user': dict(user)}), 200


# ─── CHANGE PASSWORD ─────────────────────────────────────────────────────────

@auth_bp.route('/change-password', methods=['POST'])
@jwt_required()
def change_password():
    user_id = int(get_jwt_identity())
    data = request.get_json()
    current_password = data.get('current_password')
    new_password = data.get('new_password')

    if not current_password or not new_password:
        return jsonify({'error': 'Missing required fields'}), 400

    if len(new_password) < 8:
        return jsonify({'error': 'Password must be at least 8 characters'}), 400

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT password_hash FROM users WHERE id = %s", (user_id,))
    user = cursor.fetchone()

    if not user or not check_password_hash(user['password_hash'], current_password):
        cursor.close()
        conn.close()
        return jsonify({'error': 'Current password is incorrect'}), 401

    new_hash = generate_password_hash(new_password)
    cursor.execute("UPDATE users SET password_hash = %s WHERE id = %s", (new_hash, user_id))
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Password changed successfully'}), 200


# ─── UPLOAD PROFILE PICTURE ──────────────────────────────────────────────────

@auth_bp.route('/upload-picture', methods=['POST'])
@jwt_required()
def upload_picture():
    user_id = int(get_jwt_identity())

    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400

    file = request.files['file']

    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400

    if not allowed_file(file.filename):
        return jsonify({'error': 'Only PNG, JPG, JPEG files allowed'}), 400

    filename = secure_filename(f"user_{user_id}.{file.filename.rsplit('.', 1)[1].lower()}")
    filepath = os.path.join(PROFILE_PICS_DIR, filename)
    file.save(filepath)

    profile_picture_url = f"/media/profiles/{filename}"

    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("""
        UPDATE users SET profile_picture_url = %s WHERE id = %s
        RETURNING id, email, full_name, role, profile_picture_url
    """, (profile_picture_url, user_id))
    user = cursor.fetchone()
    conn.commit()
    cursor.close()
    conn.close()

    return jsonify({'message': 'Profile picture updated', 'user': dict(user)}), 200