from database import get_db_connection


def update_recommendation(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()

    try:
        # Get total time spent per format
        cursor.execute("""
            SELECT format, SUM(time_spent_seconds) as total_time
            FROM format_tracking
            WHERE user_id = %s
            GROUP BY format
        """, (user_id,))
        time_data = {row['format']: row['total_time'] for row in cursor.fetchall()}

        # Get average quiz score per format used
        cursor.execute("""
            SELECT format_used, AVG(total_score) as avg_score
            FROM quiz_attempts
            WHERE user_id = %s AND format_used IS NOT NULL
            GROUP BY format_used
        """, (user_id,))
        score_data = {row['format_used']: float(row['avg_score'])
                      for row in cursor.fetchall()}

        # Calculate combined score per format
        all_formats = ['english', 'urdu', 'audio_en', 'audio_ur', 'visual', 'lecture']
        format_scores = {}

        for fmt in all_formats:
            time = time_data.get(fmt, 0)
            avg_score = score_data.get(fmt, 50)
            combined = (time * 0.7) + (avg_score * 0.3 * 10)
            format_scores[fmt] = combined

        # Only recommend if we have enough data
        total_time = sum(time_data.values()) if time_data else 0
        if total_time < 10:
            cursor.close()
            conn.close()
            return

        # Pick format with highest combined score
        recommended = max(format_scores, key=format_scores.get)

        # Update user_preferences
        cursor.execute("""
            INSERT INTO user_preferences (user_id, recommended_format, updated_at)
            VALUES (%s, %s, NOW())
            ON CONFLICT (user_id)
            DO UPDATE SET recommended_format = %s, updated_at = NOW()
        """, (user_id, recommended, recommended))

        conn.commit()

        # Update vark_assessments separately
        vark_map = {
            'english': 'reading',
            'urdu': 'reading',
            'audio_en': 'auditory',
            'audio_ur': 'auditory',
            'visual': 'visual',
            'lecture': 'auditory',  # lecture has audio narration — auditory category
        }

        vark_scores = {'visual': 0.0, 'auditory': 0.0, 'reading': 0.0}
        for fmt, score in format_scores.items():
            category = vark_map.get(fmt, 'reading')
            vark_scores[category] += score

        max_score = max(vark_scores.values()) or 1
        visual_s = round((vark_scores['visual'] / max_score) * 10)
        auditory_s = round((vark_scores['auditory'] / max_score) * 10)
        reading_s = round((vark_scores['reading'] / max_score) * 10)

        vark_recommended = max(
            ['visual', 'auditory', 'reading'],
            key=lambda x: vark_scores[x]
        )

        # Check if vark assessment exists for this user
        cursor.execute(
            "SELECT id FROM vark_assessments WHERE user_id = %s ORDER BY assessed_at DESC LIMIT 1",
            (user_id,)
        )
        existing_vark = cursor.fetchone()

        if existing_vark:
            cursor.execute("""
                UPDATE vark_assessments
                SET visual_score = %s, auditory_score = %s,
                    reading_score = %s, kinesthetic_score = 0,
                    recommended_format = %s, assessed_at = NOW()
                WHERE id = %s
            """, (visual_s, auditory_s, reading_s, vark_recommended, existing_vark['id']))
        else:
            cursor.execute("""
                INSERT INTO vark_assessments
                (user_id, visual_score, auditory_score, reading_score,
                 kinesthetic_score, recommended_format)
                VALUES (%s, %s, %s, %s, 0, %s)
            """, (user_id, visual_s, auditory_s, reading_s, vark_recommended))

        conn.commit()

    except Exception as e:
        conn.rollback()
        print(f'Adaptive engine error: {e}')
    finally:
        cursor.close()
        conn.close()