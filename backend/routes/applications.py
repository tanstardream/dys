from flask import Blueprint, request, jsonify, send_file, current_app
from werkzeug.utils import secure_filename
import os
import json
from datetime import datetime
from models.models import db, Application, Job
from routes.auth import token_required
from utils.resume_generator import generate_resume_docx

applications_bp = Blueprint('applications', __name__)

ALLOWED_EXTENSIONS = {'pdf', 'doc', 'docx'}

def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@applications_bp.route('/', methods=['POST'])
def create_application():
    """提交简历申请（公开接口）"""
    # 检查是表单数据还是JSON数据
    if request.content_type and 'multipart/form-data' in request.content_type:
        # 文件上传模式
        data = request.form.to_dict()
        file = request.files.get('resume')
        
        if not file or not allowed_file(file.filename):
            return jsonify({'error': 'Invalid file type. Only PDF, DOC, DOCX allowed'}), 400
        
        # 保存文件
        filename = secure_filename(f"{datetime.now().strftime('%Y%m%d%H%M%S')}_{file.filename}")
        upload_path = os.path.join(current_app.config['UPLOAD_FOLDER'], 'resumes', filename)
        os.makedirs(os.path.dirname(upload_path), exist_ok=True)
        file.save(upload_path)
        
        resume_file = f'resumes/{filename}'
        resume_type = 'uploaded'
    else:
        # 在线填写模式
        data = request.get_json()
        resume_file = None
        resume_type = 'form'
        
        # 如果需要生成Word简历
        if data.get('generate_resume'):
            try:
                resume_data = {
                    'name': data['name'],
                    'email': data['email'],
                    'phone': data['phone'],
                    'education': json.loads(data.get('education', '[]')),
                    'work_experience': json.loads(data.get('work_experience', '[]')),
                    'skills': json.loads(data.get('skills', '[]')),
                    'self_introduction': data.get('self_introduction', '')
                }
                
                filename = generate_resume_docx(resume_data)
                resume_file = f'generated/{filename}'
                resume_type = 'generated'
            except Exception as e:
                return jsonify({'error': f'Failed to generate resume: {str(e)}'}), 500
    
    # 验证必填字段
    required_fields = ['job_id', 'name', 'email', 'phone']
    for field in required_fields:
        if not data.get(field):
            return jsonify({'error': f'{field} is required'}), 400
    
    # 验证职位是否存在
    job = Job.query.get(data['job_id'])
    if not job:
        return jsonify({'error': 'Job not found'}), 404
    
    if job.status != 'active':
        return jsonify({'error': 'This job is no longer accepting applications'}), 400
    
    # 创建申请
    application = Application(
        job_id=data['job_id'],
        name=data['name'],
        email=data['email'],
        phone=data['phone'],
        education=data.get('education'),
        work_experience=data.get('work_experience'),
        skills=data.get('skills'),
        self_introduction=data.get('self_introduction'),
        resume_file=resume_file,
        resume_type=resume_type
    )
    
    db.session.add(application)
    db.session.commit()
    
    return jsonify({
        'message': 'Application submitted successfully',
        'application_id': application.id
    }), 201

@applications_bp.route('/', methods=['GET'])
@token_required
def get_applications(current_user):
    """获取简历列表（管理员）"""
    job_id = request.args.get('job_id', type=int)
    status = request.args.get('status')
    page = request.args.get('page', 1, type=int)
    per_page = request.args.get('per_page', 20, type=int)
    
    query = Application.query
    
    if job_id:
        query = query.filter_by(job_id=job_id)
    if status:
        query = query.filter_by(status=status)
    
    pagination = query.order_by(Application.created_at.desc()).paginate(
        page=page, per_page=per_page, error_out=False
    )
    
    return jsonify({
        'applications': [app.to_dict(include_job=True) for app in pagination.items],
        'total': pagination.total,
        'page': page,
        'per_page': per_page,
        'pages': pagination.pages
    }), 200

@applications_bp.route('/<int:app_id>', methods=['GET'])
@token_required
def get_application(current_user, app_id):
    """获取单个简历详情"""
    application = Application.query.get(app_id)
    if not application:
        return jsonify({'error': 'Application not found'}), 404
    
    return jsonify(application.to_dict(include_job=True)), 200

@applications_bp.route('/<int:app_id>', methods=['PUT'])
@token_required
def update_application(current_user, app_id):
    """更新简历状态/备注"""
    application = Application.query.get(app_id)
    if not application:
        return jsonify({'error': 'Application not found'}), 404
    
    data = request.get_json()
    
    if 'status' in data:
        application.status = data['status']
    if 'notes' in data:
        application.notes = data['notes']
    
    db.session.commit()
    
    return jsonify(application.to_dict(include_job=True)), 200

@applications_bp.route('/<int:app_id>/download', methods=['GET'])
@token_required
def download_resume(current_user, app_id):
    """下载简历文件"""
    application = Application.query.get(app_id)
    if not application:
        return jsonify({'error': 'Application not found'}), 404
    
    if not application.resume_file:
        return jsonify({'error': 'No resume file available'}), 404
    
    file_path = os.path.join(current_app.config['UPLOAD_FOLDER'], application.resume_file)
    
    if not os.path.exists(file_path):
        return jsonify({'error': 'Resume file not found'}), 404
    
    # 生成下载文件名：申请人姓名_职位名称_简历.后缀
    file_ext = os.path.splitext(application.resume_file)[1]
    job_title = application.job.title if application.job else '职位'
    download_name = f"{application.name}_{job_title}_简历{file_ext}"
    
    return send_file(
        file_path,
        as_attachment=True,
        download_name=download_name
    )

@applications_bp.route('/stats', methods=['GET'])
@token_required
def get_stats(current_user):
    """获取统计数据"""
    total_applications = Application.query.count()
    pending = Application.query.filter_by(status='pending').count()
    reviewing = Application.query.filter_by(status='reviewing').count()
    interviewed = Application.query.filter_by(status='interviewed').count()
    offered = Application.query.filter_by(status='offered').count()
    rejected = Application.query.filter_by(status='rejected').count()
    
    return jsonify({
        'total': total_applications,
        'pending': pending,
        'reviewing': reviewing,
        'interviewed': interviewed,
        'offered': offered,
        'rejected': rejected
    }), 200
