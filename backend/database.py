import os
import psycopg2
from psycopg2.extras import RealDictCursor
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv('DATABASE_URL')

def get_db_connection():
    """
    Create database connection
    Returns connection object
    """
    conn = psycopg2.connect(DATABASE_URL, cursor_factory=RealDictCursor)
    return conn

def get_all_paragraphs():
    """
    Retrieve all paragraphs from topics table
    Returns list of dictionaries with paragraph text and metadata
    """
    conn = get_db_connection()
    cursor = conn.cursor()
    
    cursor.execute("""
        SELECT 
            topic_id,
            topic_name,
            paragraph_1,
            paragraph_2,
            paragraph_3,
            paragraph_4,
            paragraph_5
        FROM topics
        ORDER BY topic_id
    """)
    
    topics = cursor.fetchall()
    cursor.close()
    conn.close()
    
    paragraphs = []
    
    for topic in topics:
        for i in range(1, 6):
            para_key = f'paragraph_{i}'
            if topic[para_key]:
                paragraphs.append({
                    'topic_id': topic['topic_id'],
                    'topic_name': topic['topic_name'],
                    'paragraph_number': i,
                    'text': topic[para_key],
                    'citation': f"Chapter 1, Topic {topic['topic_id']}, Paragraph {i}"
                })
    
    return paragraphs

if __name__ == "__main__":
    print("Testing database connection...")
    paragraphs = get_all_paragraphs()
    print(f"Retrieved {len(paragraphs)} paragraphs from database")
    print(f"First paragraph: {paragraphs[0]['text'][:100]}...")