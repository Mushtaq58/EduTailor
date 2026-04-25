from datetime import datetime
from werkzeug.security import generate_password_hash, check_password_hash

class User:
    @staticmethod
    def create(conn, email, password, full_name, role='student'):
        cursor = conn.cursor()
        password_hash = generate_password_hash(password)
        
        cursor.execute("""
            INSERT INTO users (email, password_hash, full_name, role, created_at)
            VALUES (%s, %s, %s, %s, %s)
            RETURNING id, email, full_name, role, created_at
        """, (email, password_hash, full_name, role, datetime.now()))
        
        user = cursor.fetchone()
        conn.commit()
        cursor.close()
        user_dict = dict(user)
        user_dict['id'] = str(user_dict['id'])
        return user_dict
    
    @staticmethod
    def find_by_email(conn, email):
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM users WHERE email = %s", (email,))
        user = cursor.fetchone()
        cursor.close()
        if user:
            user_dict = dict(user)
            user_dict['id'] = str(user_dict['id'])
            return user_dict
        return None
    
    @staticmethod
    def verify_password(stored_hash, password):
        return check_password_hash(stored_hash, password)
    
    @staticmethod
    def update_last_login(conn, user_id):
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE users SET last_login = %s WHERE id = %s
        """, (datetime.now(), user_id))
        conn.commit()
        cursor.close()