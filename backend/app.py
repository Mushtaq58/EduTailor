from flask import Flask, jsonify, send_from_directory
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from config import Config
from routes import auth_bp, topics_bp, quiz_bp, qa_bp, teacher_bp, reviews_bp, content_bp
from routes.adaptive import adaptive_bp
from routes.admin import admin_bp
from routes.notes import notes_bp
import os

app = Flask(__name__)
app.config.from_object(Config)

CORS(app)
jwt = JWTManager(app)

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(topics_bp, url_prefix='/api')
app.register_blueprint(quiz_bp, url_prefix='/api/quiz')
app.register_blueprint(qa_bp, url_prefix='/api/qa')
app.register_blueprint(teacher_bp, url_prefix='/api/teacher')
app.register_blueprint(reviews_bp, url_prefix='/api/reviews')
app.register_blueprint(content_bp, url_prefix='/api')
app.register_blueprint(adaptive_bp, url_prefix='/api/adaptive')
app.register_blueprint(admin_bp, url_prefix='/api/admin')
app.register_blueprint(notes_bp, url_prefix='/api/notes')

# ── Serve media files ──
MEDIA_DIR = os.path.join(os.path.dirname(__file__), 'media')

@app.route('/media/<path:filename>')
def serve_media(filename):
    return send_from_directory(MEDIA_DIR, filename)

@app.route('/api/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'healthy', 'message': 'EduTailor API is running'}), 200

@app.errorhandler(404)
def not_found(error):
    return jsonify({'error': 'Endpoint not found'}), 404

@app.errorhandler(500)
def internal_error(error):
    return jsonify({'error': 'Internal server error'}), 500

if __name__ == '__main__':
    debug = os.environ.get('FLASK_ENV') != 'production'
    app.run(host='0.0.0.0', debug=debug, port=5000)