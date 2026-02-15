# 招聘网站系统

这是一个完整的招聘网站系统，包含外部人员的简历投递页面和内部管理人员的管理后台。

## 功能特性

### 外部投递页面
- 职位列表展示
- 职位详情查看
- 两种简历提交方式：
  - 直接上传简历文件（支持PDF、DOC、DOCX）
  - 在线填写简历信息并自动生成Word文档

### 内部管理页面
- 用户登录认证（基于JWT）
- 数据统计看板
- 职位管理（发布、编辑、删除职位）
- 简历管理（查看、筛选、更新状态、下载简历）
- 支持的简历状态：待处理、审核中、已面试、已录用、已拒绝

## 技术栈

### 后端
- **框架**: Flask
- **数据库**: SQLite
- **认证**: JWT (JSON Web Token)
- **文档处理**: python-docx

### 前端
- **技术**: HTML + CSS + JavaScript
- **样式**: 原生CSS，响应式设计
- **API调用**: Fetch API

## 项目结构

```
.
├── backend/                # 后端代码
│   ├── models/            # 数据模型
│   │   ├── __init__.py
│   │   └── models.py      # User, Job, Application模型
│   ├── routes/            # API路由
│   │   ├── __init__.py
│   │   ├── auth.py        # 认证相关API
│   │   ├── jobs.py        # 职位相关API
│   │   └── applications.py # 简历相关API
│   ├── utils/             # 工具函数
│   │   ├── __init__.py
│   │   └── resume_generator.py # Word简历生成器
│   ├── app.py             # Flask应用入口
│   └── requirements.txt   # Python依赖
├── frontend/              # 前端代码
│   ├── index.html         # 外部投递页面
│   └── admin.html         # 管理后台页面
├── uploads/               # 上传文件存储
│   ├── resumes/          # 上传的简历
│   └── generated/        # 自动生成的简历
└── README.md             # 项目文档
```

## 安装和运行

### 1. 安装依赖

进入backend目录并安装Python依赖：

```bash
cd backend
pip install -r requirements.txt
```

### 2. 运行后端服务

```bash
cd backend
python app.py
```

后端服务将在 `http://localhost:5000` 启动。

首次运行会自动创建数据库并生成默认管理员账号：
- 用户名: `admin`
- 密码: `admin123`

### 3. 访问前端页面

**外部投递页面**: 
在浏览器中打开 `frontend/index.html`

**管理后台页面**: 
在浏览器中打开 `frontend/admin.html`

## API接口文档

### 认证相关

#### 登录
```
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin123"
}

Response:
{
  "token": "jwt_token_here",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

#### 验证Token
```
GET /api/auth/verify
Authorization: Bearer {token}

Response:
{
  "valid": true,
  "user": {...}
}
```

### 职位相关

#### 获取职位列表（公开）
```
GET /api/jobs/?status=active&page=1&per_page=10

Response:
{
  "jobs": [...],
  "total": 10,
  "page": 1,
  "per_page": 10,
  "pages": 1
}
```

#### 获取职位详情（公开）
```
GET /api/jobs/{job_id}

Response:
{
  "id": 1,
  "title": "Python开发工程师",
  "department": "技术部",
  ...
}
```

#### 创建职位（需要认证）
```
POST /api/jobs/
Authorization: Bearer {token}
Content-Type: application/json

{
  "title": "Python开发工程师",
  "department": "技术部",
  "location": "北京",
  "job_type": "full-time",
  "salary_range": "15K-25K",
  "description": "职位描述...",
  "requirements": "职位要求...",
  "responsibilities": "工作职责..."
}
```

#### 更新职位（需要认证）
```
PUT /api/jobs/{job_id}
Authorization: Bearer {token}
Content-Type: application/json

{更新的字段...}
```

#### 删除职位（需要认证）
```
DELETE /api/jobs/{job_id}
Authorization: Bearer {token}
```

### 简历相关

#### 提交简历（公开）

**方式1: 上传文件**
```
POST /api/applications/
Content-Type: multipart/form-data

job_id: 1
name: 张三
email: zhangsan@example.com
phone: 13800138000
resume: [文件]
```

**方式2: 在线填写**
```
POST /api/applications/
Content-Type: application/json

{
  "job_id": 1,
  "name": "张三",
  "email": "zhangsan@example.com",
  "phone": "13800138000",
  "education": "[{\"school\":\"清华大学\",\"major\":\"计算机科学\"}]",
  "work_experience": "[...]",
  "skills": "[...]",
  "self_introduction": "...",
  "generate_resume": true  // 是否生成Word简历
}
```

#### 获取简历列表（需要认证）
```
GET /api/applications/?status=pending&job_id=1&page=1&per_page=20
Authorization: Bearer {token}
```

#### 获取简历详情（需要认证）
```
GET /api/applications/{app_id}
Authorization: Bearer {token}
```

#### 更新简历状态（需要认证）
```
PUT /api/applications/{app_id}
Authorization: Bearer {token}
Content-Type: application/json

{
  "status": "reviewing",
  "notes": "HR备注信息"
}
```

#### 下载简历（需要认证）
```
GET /api/applications/{app_id}/download
Authorization: Bearer {token}
```

#### 获取统计数据（需要认证）
```
GET /api/applications/stats
Authorization: Bearer {token}

Response:
{
  "total": 100,
  "pending": 20,
  "reviewing": 30,
  "interviewed": 25,
  "offered": 15,
  "rejected": 10
}
```

## 使用说明

### 管理员使用流程

1. 访问管理后台 (`admin.html`)
2. 使用默认账号登录 (admin/admin123)
3. 在"职位管理"中发布新职位
4. 在"简历管理"中查看和处理应聘者的简历
5. 可以更新简历状态、添加备注、下载简历文件

### 求职者使用流程

1. 访问招聘页面 (`index.html`)
2. 浏览职位列表
3. 点击感兴趣的职位查看详情
4. 选择提交方式：
   - **上传简历**: 填写基本信息并上传现有简历文件
   - **在线填写**: 填写完整的简历信息，系统自动生成Word文档
5. 提交申请

## 数据模型

### User（用户）
- id: 主键
- username: 用户名
- email: 邮箱
- password: 密码（加密存储）
- role: 角色（admin, hr, viewer）
- created_at: 创建时间

### Job（职位）
- id: 主键
- title: 职位名称
- department: 部门
- location: 工作地点
- job_type: 职位类型（full-time, part-time, contract, internship）
- salary_range: 薪资范围
- description: 职位描述
- requirements: 职位要求
- responsibilities: 工作职责
- status: 状态（active, closed, draft）
- created_at: 创建时间
- updated_at: 更新时间
- created_by: 创建者ID

### Application（简历申请）
- id: 主键
- job_id: 职位ID（外键）
- name: 姓名
- email: 邮箱
- phone: 电话
- education: 教育经历（JSON）
- work_experience: 工作经历（JSON）
- skills: 技能（JSON）
- self_introduction: 自我介绍
- resume_file: 简历文件路径
- resume_type: 简历类型（uploaded, generated, form）
- status: 状态（pending, reviewing, interviewed, offered, rejected）
- notes: HR备注
- created_at: 创建时间
- updated_at: 更新时间

## 安全建议

在生产环境部署时，请务必：

1. 修改 `backend/app.py` 中的 `SECRET_KEY`
2. 修改默认管理员密码
3. 使用HTTPS协议
4. 配置CORS白名单
5. 使用PostgreSQL或MySQL替代SQLite
6. 添加文件上传大小和类型的严格验证
7. 实现速率限制防止暴力破解
8. 定期备份数据库

## 扩展建议

可以考虑添加以下功能：

1. 邮件通知（申请提交成功、状态更新等）
2. 多语言支持
3. 更详细的权限管理
4. 简历搜索和筛选功能
5. 面试安排功能
6. 候选人评分系统
7. 数据导出功能（Excel）
8. 文件预览功能
9. 移动端适配
10. 社交媒体分享功能

## 许可证

MIT License

## 联系方式

如有问题，请联系项目维护者。
