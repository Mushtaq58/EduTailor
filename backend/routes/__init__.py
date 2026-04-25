from .auth import auth_bp
from .topics import topics_bp
from .quiz import quiz_bp
from .qa import qa_bp
from .teacher import teacher_bp
from .reviews import reviews_bp
from .content import content_bp
from .adaptive import adaptive_bp

__all__ = ['auth_bp', 'topics_bp', 'quiz_bp', 'qa_bp', 
           'teacher_bp', 'reviews_bp', 'content_bp', 'adaptive_bp']