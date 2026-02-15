from flask import Flask, send_from_directory
from flask_cors import CORS
from werkzeug.security import generate_password_hash
from datetime import datetime
import os
import sys

# Set UTF-8 encoding for Windows console
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
    except:
        pass

# Import db from models first
from models.models import db, User, Job, Application

app = Flask(__name__, 
            static_folder='../frontend',
            static_url_path='')

app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///recruitment.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'uploads')
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

CORS(app)
db.init_app(app)

# Import and register blueprints
from routes.auth import auth_bp
from routes.jobs import jobs_bp
from routes.applications import applications_bp

app.register_blueprint(auth_bp, url_prefix='/api/auth')
app.register_blueprint(jobs_bp, url_prefix='/api/jobs')
app.register_blueprint(applications_bp, url_prefix='/api/applications')

# Serve frontend pages
@app.route('/')
def index():
    """外部求职页面"""
    return send_from_directory('../frontend', 'index.html')

@app.route('/admin')
def admin():
    """管理后台页面"""
    return send_from_directory('../frontend', 'admin.html')

@app.route('/api/health', methods=['GET'])
def health_check():
    return {'status': 'healthy', 'timestamp': datetime.now().isoformat()}

def init_db():
    """Initialize database and create default admin user"""
    with app.app_context():
        db.create_all()
        
        # Create default admin user if not exists
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='admin@example.com',
                password=generate_password_hash('admin123'),
                role='admin'
            )
            db.session.add(admin)
            db.session.commit()
            print('[OK] Default admin user created: admin/admin123')
        else:
            print('[OK] Admin user already exists')


def main():
    """Main entry point for running the application"""
    init_db()
    print('\n' + '='*60)
    print('Recruitment System - Backend Server Starting...')
    print('='*60)
    print('\nAccess URLs:')
    print('- Public Page:    http://localhost:5000/')
    print('- Admin Panel:    http://localhost:5000/admin')
    print('- API Health:     http://localhost:5000/api/health')
    print('\nFor Cloud Server:')
    print('- Replace "localhost" with your server IP')
    print('- Example: http://your-server-ip:5000/')
    print('\nDefault Credentials:')
    print('Username: admin')
    print('Password: admin123')
    print('='*60 + '\n')

    # For cloud deployment, use 0.0.0.0 to listen on all interfaces
    app.run(debug=True, host='0.0.0.0', port=5000)

if __name__ == '__main__':
    main()
