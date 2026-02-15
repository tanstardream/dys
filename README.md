# 德元升中医馆 - 招聘管理系统

## 📦 系统架构

系统采用**双端口部署**架构，分离公共访问和管理功能：

```
┌─────────────────────────────────────────────┐
│  端口 5000 - 公共求职页面                    │
│  - 求职者浏览职位                            │
│  - 在线投递简历                              │
│  - 公开访问，无需登录                        │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  端口 5001 - 管理后台                        │
│  - 职位管理                                  │
│  - 简历管理                                  │
│  - 数据统计                                  │
│  - 需要登录认证                              │
└─────────────────────────────────────────────┘
```

## 🚀 快速启动

### 方式1: 使用启动脚本（推荐）

**Linux/Mac:**
```bash
# 使用 uv（推荐）
chmod +x start_all_uv.sh
./start_all_uv.sh

# 或使用标准 Python
chmod +x start_all.sh
./start_all.sh
```

**Windows:**
```cmd
start_all.bat
```

### 方式2: 手动启动

**终端1 - 启动公共页面服务:**
```bash
cd backend
uv run python app.py
# 或: python app.py
```

**终端2 - 启动管理后台服务:**
```bash
cd backend
uv run python admin_app.py
# 或: python admin_app.py
```

## 🌐 访问地址

### 本地访问
- **公共求职页面**: http://localhost:5000/
- **管理后台**: http://localhost:5001/

### 云服务器访问
- **公共求职页面**: http://your-server-ip:5000/
- **管理后台**: http://your-server-ip:5001/

## 🔐 默认管理员账号

- **用户名**: `admin`
- **密码**: `admin123`

⚠️ **生产环境请务必修改默认密码！**

## 📁 项目结构

```
dys/
├── backend/                    # 后端代码
│   ├── app.py                 # 公共服务 (5000端口)
│   ├── admin_app.py           # 管理服务 (5001端口)
│   ├── models/                # 数据模型
│   ├── routes/                # API路由
│   │   ├── auth.py           # 认证
│   │   ├── jobs.py           # 职位管理
│   │   ├── applications.py   # 简历管理
│   │   └── users.py          # 用户密码管理
│   └── instance/              # 数据库文件
├── frontend/                   # 前端代码
│   ├── index.html            # 公共求职页面
│   └── admin.html            # 管理后台页面
├── start_all.sh               # Linux/Mac 启动脚本
├── start_all.bat              # Windows 启动脚本
└── start_all_uv.sh            # uv 启动脚本
```

## ⚙️ 端口配置

如需修改端口，编辑以下文件：

**修改公共服务端口 (默认5000):**
```python
# backend/app.py 第91行
app.run(debug=True, host='0.0.0.0', port=5000)  # 修改此处
```

**修改管理服务端口 (默认5001):**
```python
# backend/admin_app.py 第95行
admin_app.run(debug=True, host='0.0.0.0', port=5001)  # 修改此处
```

## 🛡️ 安全建议

1. **修改默认密码**: 登录后立即在管理后台修改密码
2. **防火墙配置**: 云服务器建议只开放5000端口，5001端口仅允许内网访问
3. **HTTPS部署**: 生产环境使用 Nginx + SSL 证书
4. **修改SECRET_KEY**: 修改 `app.py` 和 `admin_app.py` 中的 SECRET_KEY

## 📝 功能特性

### 公共求职页面 (5000)
- ✅ 职位列表浏览
- ✅ 职位详情查看
- ✅ 在线简历投递
- ✅ 简历模板填写
- ✅ 简历文件上传

### 管理后台 (5001)
- ✅ 用户登录认证
- ✅ 职位增删改查
- ✅ 简历筛选管理
- ✅ 数据统计展示
- ✅ 个人密码修改

## 🔧 依赖安装

```bash
# 使用 uv（推荐）
uv pip install -r requirements.txt

# 或使用 pip
pip install flask flask-cors flask-sqlalchemy werkzeug pyjwt
```

## 📮 技术支持

如有问题，请访问项目仓库提交 Issue。
