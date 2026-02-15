#!/usr/bin/env python3
"""
管理后台应用 - 运行在5001端口
"""

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
from models.models import db, User

# Create admin app
admin_app = Flask(__name__,
                  static_folder='../frontend',
                  static_url_path='')

admin_app.config['SECRET_KEY'] = 'your-secret-key-change-in-production'
admin_app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///recruitment.db'
admin_app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
admin_app.config['UPLOAD_FOLDER'] = os.path.join(os.path.dirname(os.path.dirname(__file__)), 'uploads')
admin_app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB max file size

CORS(admin_app)
db.init_app(admin_app)

# Import and register blueprints - 只注册管理相关的API
from routes.auth import auth_bp
from routes.jobs import jobs_bp
from routes.applications import applications_bp
from routes.users import users_bp

admin_app.register_blueprint(auth_bp, url_prefix='/api/auth')
admin_app.register_blueprint(jobs_bp, url_prefix='/api/jobs')
admin_app.register_blueprint(applications_bp, url_prefix='/api/applications')
admin_app.register_blueprint(users_bp, url_prefix='/api/users')

# Serve admin page
@admin_app.route('/')
def admin():
    """管理后台页面"""
    return send_from_directory('../frontend', 'admin.html')

@admin_app.route('/api/health', methods=['GET'])
def health_check():
    return {'status': 'healthy', 'timestamp': datetime.now().isoformat()}

def init_db():
    """Initialize database and create default admin user"""
    with admin_app.app_context():
        db.create_all()

        # Create default admin user if not exists
        admin = User.query.filter_by(username='admin').first()
        if not admin:
            admin = User(
                username='admin',
                email='admin@example.com',
                password=generate_password_hash('admin123'),
                role='super_admin'
            )
            db.session.add(admin)
            db.session.commit()
            print('[OK] Default super admin user created: admin/admin123')
        else:
            print('[OK] Admin user already exists')


def main():
    """Main entry point for running the admin application"""
    init_db()
    print('\n' + '='*60)
    print('Recruitment System - Admin Panel Starting...')
    print('='*60)
    print('\nAccess URLs:')
    print('- Admin Panel:    http://localhost:5001/')
    print('- API Health:     http://localhost:5001/api/health')
    print('\nFor Cloud Server:')
    print('- Replace "localhost" with your server IP')
    print('- Example: http://your-server-ip:5001/')
    print('\nDefault Credentials:')
    print('Username: admin')
    print('Password: admin123')
    print('='*60 + '\n')

    # For cloud deployment, use 0.0.0.0 to listen on all interfaces
    admin_app.run(debug=True, host='0.0.0.0', port=5001)

if __name__ == '__main__':
    main()
