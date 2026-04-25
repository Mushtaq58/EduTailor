from datetime import datetime

class StudentProgress:
    @staticmethod
    def get_or_create(conn, user_id, topic_id):
        cursor = conn.cursor()
        
        cursor.execute("""
            SELECT * FROM student_progress
            WHERE user_id = %s AND topic_id = %s
        """, (user_id, topic_id))
        
        progress = cursor.fetchone()
        
        if not progress:
            cursor.execute("""
                INSERT INTO student_progress (user_id, topic_id, status, attempts_count)
                VALUES (%s, %s, 'not_started', 0)
                RETURNING *
            """, (user_id, topic_id))
            progress = cursor.fetchone()
            conn.commit()
        
        cursor.close()
        return dict(progress)
    
    @staticmethod
    def update_status(conn, user_id, topic_id, status):
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE student_progress
            SET status = %s, last_accessed = %s
            WHERE user_id = %s AND topic_id = %s
        """, (status, datetime.now(), user_id, topic_id))
        conn.commit()
        cursor.close()
    
    @staticmethod
    def update_quiz_score(conn, user_id, topic_id, score):
        cursor = conn.cursor()
        cursor.execute("""
            UPDATE student_progress
            SET 
                best_score = GREATEST(COALESCE(best_score, 0), %s),
                attempts_count = attempts_count + 1,
                status = CASE WHEN %s >= 70 THEN 'completed' ELSE 'in_progress' END,
                completed_at = CASE WHEN %s >= 70 THEN %s ELSE completed_at END
            WHERE user_id = %s AND topic_id = %s
        """, (score, score, score, datetime.now(), user_id, topic_id))
        conn.commit()
        cursor.close()
    
    @staticmethod
    def get_user_progress(conn, user_id):
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                sp.*,
                t.topic_name
            FROM student_progress sp
            JOIN topics t ON sp.topic_id = t.topic_id
            WHERE sp.user_id = %s
            ORDER BY sp.topic_id
        """, (user_id,))
        
        progress = cursor.fetchall()
        cursor.close()
        return [dict(p) for p in progress]