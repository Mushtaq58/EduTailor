from datetime import datetime
import json

class QuizAttempt:
    @staticmethod
    def create(conn, user_id, topic_id, format_used, mcq_score, subjective_score, 
               total_score, mcq_responses, subjective_responses, 
               time_spent_learning, quiz_duration):
        cursor = conn.cursor()
        
        cursor.execute("""
            INSERT INTO quiz_attempts (
                user_id, topic_id, format_used,
                mcq_score, subjective_score, total_score,
                mcq_responses, subjective_responses,
                time_spent_learning_seconds, quiz_duration_seconds,
                attempted_at
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            RETURNING id
        """, (
            user_id, topic_id, format_used,
            mcq_score, subjective_score, total_score,
            json.dumps(mcq_responses), json.dumps(subjective_responses),
            time_spent_learning, quiz_duration,
            datetime.now()
        ))
        
        result = cursor.fetchone()
        conn.commit()
        cursor.close()
        return result['id']
    
    @staticmethod
    def get_user_attempts(conn, user_id, topic_id=None):
        cursor = conn.cursor()
        
        if topic_id:
            cursor.execute("""
                SELECT * FROM quiz_attempts
                WHERE user_id = %s AND topic_id = %s
                ORDER BY attempted_at DESC
            """, (user_id, topic_id))
        else:
            cursor.execute("""
                SELECT * FROM quiz_attempts
                WHERE user_id = %s
                ORDER BY attempted_at DESC
            """, (user_id,))
        
        attempts = cursor.fetchall()
        cursor.close()
        return [dict(a) for a in attempts]
    
    @staticmethod
    def get_format_performance(conn, user_id):
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                format_used,
                COUNT(*) as attempt_count,
                AVG(total_score) as avg_score,
                MAX(total_score) as best_score
            FROM quiz_attempts
            WHERE user_id = %s
            GROUP BY format_used
        """, (user_id,))
        
        results = cursor.fetchall()
        cursor.close()
        return [dict(r) for r in results]