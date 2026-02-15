from datetime import datetime
from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

class User(db.Model):
    """用户模型 - 用于内部管理人员登录"""
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)
    email = db.Column(db.String(120), unique=True, nullable=False)
    password = db.Column(db.String(255), nullable=False)
    role = db.Column(db.String(20), default='admin')  # admin, hr, viewer
    created_at = db.Column(db.DateTime, default=datetime.now)
    
    def to_dict(self):
        return {
            'id': self.id,
            'username': self.username,
            'email': self.email,
            'role': self.role,
            'created_at': self.created_at.isoformat()
        }


class Job(db.Model):
    """职位模型"""
    __tablename__ = 'jobs'
    
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(200), nullable=False)
    department = db.Column(db.String(100), nullable=False)
    location = db.Column(db.String(100), nullable=False)
    job_type = db.Column(db.String(50), nullable=False)  # full-time, part-time, contract
    salary_range = db.Column(db.String(100))
    description = db.Column(db.Text, nullable=False)
    requirements = db.Column(db.Text, nullable=False)
    responsibilities = db.Column(db.Text, nullable=False)
    status = db.Column(db.String(20), default='active')  # active, closed, draft
    category = db.Column(db.String(50), default='技术人员')  # 管理, 技术人员, 保洁人员
    priority = db.Column(db.Integer, default=99)  # 优先级，数字越小越靠前
    position_count = db.Column(db.Integer, default=1)  # 招聘人数
    category = db.Column(db.String(50), default='技术人员')  # 管理, 技术人员, 保洁人员
    priority = db.Column(db.Integer, default=99)  # 优先级，数字越小越靠前
    position_count = db.Column(db.Integer, default=1)  # 招聘人数
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    created_by = db.Column(db.Integer, db.ForeignKey('users.id'))
    
    # Relationships
    applications = db.relationship('Application', backref='job', lazy=True, cascade='all, delete-orphan')
    
    def to_dict(self):
        return {
            'id': self.id,
            'title': self.title,
            'department': self.department,
            'location': self.location,
            'job_type': self.job_type,
            'salary_range': self.salary_range,
            'description': self.description,
            'requirements': self.requirements,
            'responsibilities': self.responsibilities,
            'status': self.status,
            'category': self.category,
            'priority': self.priority,
            'position_count': self.position_count,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat(),
            'application_count': len(self.applications)
        }


class Application(db.Model):
    """简历申请模型"""
    __tablename__ = 'applications'
    
    id = db.Column(db.Integer, primary_key=True)
    job_id = db.Column(db.Integer, db.ForeignKey('jobs.id'), nullable=False)
    
    # 申请人基本信息
    name = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(120), nullable=False)
    phone = db.Column(db.String(20), nullable=False)
    
    # 详细信息（如果使用模板填写）
    education = db.Column(db.Text)  # JSON格式存储教育经历
    work_experience = db.Column(db.Text)  # JSON格式存储工作经历
    skills = db.Column(db.Text)  # JSON格式存储技能
    self_introduction = db.Column(db.Text)  # 自我介绍
    
    # 简历文件
    resume_file = db.Column(db.String(255))  # 上传或生成的简历文件路径
    resume_type = db.Column(db.String(20))  # uploaded 或 generated
    
    # 申请状态
    status = db.Column(db.String(20), default='pending')  # pending, reviewing, interviewed, offered, rejected
    notes = db.Column(db.Text)  # HR备注
    
    created_at = db.Column(db.DateTime, default=datetime.now)
    updated_at = db.Column(db.DateTime, default=datetime.now, onupdate=datetime.now)
    
    def to_dict(self, include_job=False):
        data = {
            'id': self.id,
            'job_id': self.job_id,
            'name': self.name,
            'email': self.email,
            'phone': self.phone,
            'education': self.education,
            'work_experience': self.work_experience,
            'skills': self.skills,
            'self_introduction': self.self_introduction,
            'resume_file': self.resume_file,
            'resume_type': self.resume_type,
            'status': self.status,
            'notes': self.notes,
            'created_at': self.created_at.isoformat(),
            'updated_at': self.updated_at.isoformat()
        }
        
        if include_job and self.job:
            data['job'] = {
                'id': self.job.id,
                'title': self.job.title,
                'department': self.job.department
            }
        
        return data
