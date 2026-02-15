from flask import Blueprint, request, jsonify
from models.models import db, Job
from routes.auth import token_required

jobs_bp = Blueprint('jobs', __name__)

@jobs_bp.route('/', methods=['GET'])
def get_jobs():
    """获取职位列表（公开，无需认证）"""
    status = request.args.get('status', 'active')
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 10, type=int)
    
    query = Job.query
    if status:
        query = query.filter_by(status=status)
    
    pagination = query.order_by(Job.created_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'jobs': [job.to_dict() for job in pagination.items],
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200

@jobs_bp.route('/<int:job_id>', methods=['GET'])
def get_job(job_id):
    """获取单个职位详情（公开）"""
    job = Job.query.get(job_id)
    if not job:
        return jsonify({'error': 'Job not found'}), 404
    
    return jsonify(job.to_dict()), 200

@jobs_bp.route('/', methods=['POST'])
@token_required
def create_job(current_user):
    """创建职位（需要认证）"""
    data = request.get_json()
    
    required_fields = ['title', 'department', 'location', 'job_type', 'description', 'requirements', 'responsibilities']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} is required'}), 400
    
    job = Job(
        title=data['title'],
        department=data['department'],
        location=data['location'],
        job_type=data['job_type'],
        salary_range=data.get('salary_range', ''),
        description=data['description'],
        requirements=data['requirements'],
        responsibilities=data['responsibilities'],
        category=data.get('category', '技术人员'),
        position_count=data.get('position_count', 1),
        priority=data.get('priority', 99),
        status=data.get('status', 'active'),
        created_by=current_user.id
    )
    
    db.session.add(job)
    db.session.commit()
    
    return jsonify(job.to_dict()), 201

@jobs_bp.route('/<int:job_id>', methods=['PUT'])
@token_required
def update_job(current_user, job_id):
    """更新职位"""
    job = Job.query.get(job_id)
    if not job:
        return jsonify({'error': 'Job not found'}), 404
    
    data = request.get_json()
    
    # Update fields
    updatable_fields = ['title', 'department', 'location', 'job_type', 'salary_range', 
                       'description', 'requirements', 'responsibilities', 
                       'category', 'position_count', 'priority', 'status']
    for field in updatable_fields:
        if field in data:
            setattr(job, field, data[field])
    
    db.session.commit()
    
    return jsonify(job.to_dict()), 200

@jobs_bp.route('/<int:job_id>', methods=['DELETE'])
@token_required
def delete_job(current_user, job_id):
    """删除职位"""
    job = Job.query.get(job_id)
    if not job:
        return jsonify({'error': 'Job not found'}), 404
    
    db.session.delete(job)
    db.session.commit()
    
    return jsonify({'message': 'Job deleted successfully'}), 200
