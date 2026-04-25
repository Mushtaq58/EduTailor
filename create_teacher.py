import psycopg2
import psycopg2.extras
import sys
import os
from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv(os.path.join(os.path.dirname(__file__), '.env'))

DATABASE_URL = os.getenv('DATABASE_URL', 'postgresql://postgres:admin123@localhost:5432/edutailor')

def create_teacher():
    print("=" * 50)
    print("   EduTailor — Create Teacher Account")
    print("=" * 50)

    full_name = input("\nFull Name: ").strip()
    email = input("Email: ").strip().lower()
    password = input("Password: ").strip()

    if not full_name or not email or not password:
        print("\nError: All fields are required.")
        sys.exit(1)

    if len(password) < 8:
        print("\nError: Password must be at least 8 characters.")
        sys.exit(1)

    password_hash = generate_password_hash(password)

    try:
        conn = psycopg2.connect(DATABASE_URL, cursor_factory=psycopg2.extras.RealDictCursor)
        cursor = conn.cursor()

        cursor.execute("SELECT id FROM users WHERE email = %s", (email,))
        if cursor.fetchone():
            print(f"\nError: Email '{email}' is already registered.")
            cursor.close()
            conn.close()
            sys.exit(1)

        cursor.execute("""
            INSERT INTO users (email, password_hash, full_name, role, is_verified, created_at)
            VALUES (%s, %s, %s, 'teacher', TRUE, NOW())
            RETURNING id, email, full_name, role
        """, (email, password_hash, full_name))

        teacher = cursor.fetchone()
        conn.commit()
        cursor.close()
        conn.close()

        print("\n" + "=" * 50)
        print("   Teacher account created successfully!")
        print("=" * 50)
        print(f"   ID:    {teacher['id']}")
        print(f"   Name:  {teacher['full_name']}")
        print(f"   Email: {teacher['email']}")
        print(f"   Role:  {teacher['role']}")
        print("=" * 50)

    except Exception as e:
        print(f"\nDatabase error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    create_teacher()