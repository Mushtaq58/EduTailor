from database import db
from datetime import datetime

class User(db.Model):
    __tablename__ = 'users'
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), unique=True, nullable=False)
    password_hash = db.Column(db.Text, nullable=False)
    role = db.Column(db.String(50), default='student')
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

class Chapter(db.Model):
    __tablename__ = 'chapters'
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(255), nullable=False)
    order_index = db.Column(db.Integer, default=0)

class Topic(db.Model):
    __tablename__ = 'topics'
    id = db.Column(db.Integer, primary_key=True)
    chapter_id = db.Column(db.Integer, db.ForeignKey('chapters.id'))
    title = db.Column(db.String(255), nullable=False)
    order_index = db.Column(db.Integer, default=0)
    visual_type = db.Column(db.String(50), default='diagram')

class ContentStatus(db.Model):
    __tablename__ = 'content_status'
    id = db.Column(db.Integer, primary_key=True)
    topic_id = db.Column(db.Integer, db.ForeignKey('topics.id'))
    english_content = db.Column(db.Text)
    urdu_content = db.Column(db.Text)
    audio_url = db.Column(db.Text)
    visual_url = db.Column(db.Text)
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)

class StudentProgress(db.Model):
    __tablename__ = 'student_progress'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    topic_id = db.Column(db.Integer, db.ForeignKey('topics.id'))
    status = db.Column(db.String(50), default='not_started')
    updated_at = db.Column(db.DateTime, default=datetime.utcnow)

class QuizAttempt(db.Model):
    __tablename__ = 'quiz_attempts'
    id = db.Column(db.Integer, primary_key=True)
    user_id = db.Column(db.Integer, db.ForeignKey('users.id'))
    topic_id = db.Column(db.Integer, db.ForeignKey('topics.id'))
    score = db.Column(db.Float, default=0)
    mcq_score = db.Column(db.Float, default=0)
    subjective_score = db.Column(db.Float, default=0)
    question_results = db.Column(db.JSON)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        topic = Topic.query.get(self.topic_id)
        return {
            'id': self.id,
            'topic_id': self.topic_id,
            'topic_title': topic.title if topic else '',
            'score': self.score,
            'mcq_score': self.mcq_score,
            'subjective_score': self.subjective_score,
            'question_results': self.question_results or {},
            'created_at': self.created_at.isoformat(),
        }