from flask import Blueprint, request, jsonify
from werkzeug.security import generate_password_hash
from models.models import db, User
from routes.auth import token_required

users_bp = Blueprint('users', __name__')

@users_bp.route('/', methods=['GET'])
@token_required
def get_users(current_user):
    """获取用户列表（仅超级管理员）"""
    if current_user.role != 'super_admin':
        return jsonify({'error': 'Permission denied. Super admin only.'}), 403

    users = User.query.all()
    return jsonify({
        'users': [user.to_dict() for user in users]
    }), 200

@users_bp.route('/', methods=['POST'])
@token_required
def create_user(current_user):
    """创建新用户（仅超级管理员）"""
    if current_user.role != 'super_admin':
        return jsonify({'error': 'Permission denied. Super admin only.'}), 403

    data = request.get_json()

    # 验证必填字段
    required_fields = ['username', 'email', 'password']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} is required'}), 400

    # 检查用户名是否已存在
    if User.query.filter_by(username=data['username']).first():
        return jsonify({'error': 'Username already exists'}), 400

    # 检查邮箱是否已存在
    if User.query.filter_by(email=data['email']).first():
        return jsonify({'error': 'Email already exists'}), 400

    # 创建新用户
    user = User(
        username=data['username'],
        email=data['email'],
        password=generate_password_hash(data['password']),
        role=data.get('role', 'admin')  # 默认为普通管理员
    )

    db.session.add(user)
    db.session.commit()

    return jsonify({
        'message': 'User created successfully',
        'user': user.to_dict()
    }), 201

@users_bp.route('/<int:user_id>', methods=['PUT'])
@token_required
def update_user(current_user, user_id):
    """更新用户信息（仅超级管理员）"""
    if current_user.role != 'super_admin':
        return jsonify({'error': 'Permission denied. Super admin only.'}), 403

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    data = request.get_json()

    # 更新用户名
    if 'username' in data and data['username'] != user.username:
        if User.query.filter_by(username=data['username']).first():
            return jsonify({'error': 'Username already exists'}), 400
        user.username = data['username']

    # 更新邮箱
    if 'email' in data and data['email'] != user.email:
        if User.query.filter_by(email=data['email']).first():
            return jsonify({'error': 'Email already exists'}), 400
        user.email = data['email']

    # 更新角色
    if 'role' in data:
        user.role = data['role']

    # 更新密码
    if 'password' in data and data['password']:
        user.password = generate_password_hash(data['password'])

    db.session.commit()

    return jsonify({
        'message': 'User updated successfully',
        'user': user.to_dict()
    }), 200

@users_bp.route('/<int:user_id>/password', methods=['PUT'])
@token_required
def change_password(current_user, user_id):
    """修改用户密码（超级管理员可以修改任何用户，普通用户只能修改自己）"""
    # 超级管理员可以修改任何用户的密码
    if current_user.role == 'super_admin':
        user = User.query.get(user_id)
        if not user:
            return jsonify({'error': 'User not found'}), 404
    # 普通用户只能修改自己的密码
    elif current_user.id == user_id:
        user = current_user
    else:
        return jsonify({'error': 'Permission denied'}), 403

    data = request.get_json()

    if not data.get('password'):
        return jsonify({'error': 'Password is required'}), 400

    user.password = generate_password_hash(data['password'])
    db.session.commit()

    return jsonify({'message': 'Password changed successfully'}), 200

@users_bp.route('/<int:user_id>', methods=['DELETE'])
@token_required
def delete_user(current_user, user_id):
    """删除用户（仅超级管理员）"""
    if current_user.role != 'super_admin':
        return jsonify({'error': 'Permission denied. Super admin only.'}), 403

    # 不允许删除自己
    if current_user.id == user_id:
        return jsonify({'error': 'Cannot delete yourself'}), 400

    user = User.query.get(user_id)
    if not user:
        return jsonify({'error': 'User not found'}), 404

    # 不允许删除其他超级管理员
    if user.role == 'super_admin':
        return jsonify({'error': 'Cannot delete super admin'}), 400

    db.session.delete(user)
    db.session.commit()

    return jsonify({'message': 'User deleted successfully'}), 200
