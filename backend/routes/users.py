from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from models.models import db, User
from routes.auth import token_required

users_bp = Blueprint('users', __name__)

@users_bp.route('/password', methods=['PUT'])
@token_required
def change_password(current_user):
    """修改当前用户密码"""
    data = request.get_json()

    if not data.get('password'):
        return jsonify({'error': 'Password is required'}), 400

    # 修改当前登录用户的密码
    current_user.password = generate_password_hash(data['password'])
    db.session.commit()

    return jsonify({'message': 'Password changed successfully'}), 200
