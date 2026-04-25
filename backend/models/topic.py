class Topic:
    @staticmethod
    def get_all_chapters(conn):
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM chapters ORDER BY chapter_number")
        chapters = cursor.fetchall()
        cursor.close()
        return [dict(c) for c in chapters]
    
    @staticmethod
    def get_all_topics(conn):
        cursor = conn.cursor()
        cursor.execute("""
            SELECT topic_id, chapter_id, topic_name, visual_type
            FROM topics
            ORDER BY topic_id
        """)
        topics = cursor.fetchall()
        cursor.close()
        return [dict(t) for t in topics]
    
    @staticmethod
    def get_topic_by_id(conn, topic_id):
        cursor = conn.cursor()
        cursor.execute("""
            SELECT 
                topic_id, chapter_id, topic_name,
                paragraph_1, paragraph_2, paragraph_3, paragraph_4, paragraph_5,
                urdu_paragraph_1, urdu_paragraph_2, urdu_paragraph_3, 
                urdu_paragraph_4, urdu_paragraph_5,
                visual_explanation, visual_type,
                audio_en_path, audio_ur_path, visual_path
            FROM topics
            WHERE topic_id = %s
        """, (topic_id,))
        topic = cursor.fetchone()
        cursor.close()
        return dict(topic) if topic else None