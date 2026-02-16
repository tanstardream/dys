# 服务器迁移指南 - 从腾讯云到京东云

## 📋 迁移信息

**源服务器（腾讯云）：**
- IP: 119.91.214.94
- 配置: 4核3.7GB
- 系统: Ubuntu 22.04

**目标服务器（京东云）：**
- IP: 111.228.59.77
- 用户名: root
- 系统: Linux
- 初始密码: 已通过短信提供（请勿在文档中保存）

---

## ⚠️ 迁移前准备（重要！）

### 1. 修改初始密码（必须）
```bash
# SSH连接到新服务器
ssh root@111.228.59.77
# 输入初始密码: degKpSS

# 立即修改密码
passwd
# 输入两次新密码（建议使用强密码）
```

### 2. 查看新服务器配置
```bash
# 查看CPU和内存
free -h
lscpu | grep "CPU(s)"

# 查看磁盘
df -h

# 查看系统版本
cat /etc/os-release
```

---

## 🚀 快速迁移（推荐方法）

### 方法1: 使用自动化脚本（最简单）

**在旧服务器（腾讯云）上：**
```bash
cd /home/ubuntu/project/dys

# 创建完整备份
./backup_for_migration.sh

# 会生成文件: dys_backup_YYYYMMDD.tar.gz
# 记录文件名，稍后需要
```

**在新服务器（京东云）上：**
```bash
# 下载并运行一键部署脚本
wget https://raw.githubusercontent.com/tanstardream/dys/main/deploy_new_server.sh
chmod +x deploy_new_server.sh
./deploy_new_server.sh
```

---

## 📦 手动迁移步骤

### 步骤1: 在新服务器上安装基础环境

```bash
# 更新系统
apt update && apt upgrade -y

# 安装Python和必要工具
apt install -y python3 python3-pip git curl wget

# 安装uv（推荐）
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.cargo/env

# 或安装pip依赖
pip3 install --upgrade pip
```

### 步骤2: 克隆项目代码

```bash
# 创建项目目录
mkdir -p /home/project
cd /home/project

# 克隆仓库
git clone https://github.com/tanstardream/dys.git
cd dys

# 安装依赖
cd backend
pip3 install flask flask-cors flask-sqlalchemy pyjwt python-docx werkzeug
pip3 install gunicorn gevent zope.event

# 或使用uv
cd backend
uv pip install flask flask-cors flask-sqlalchemy pyjwt python-docx werkzeug gunicorn gevent
```

### 步骤3: 迁移数据库和上传文件

**方法A: 使用SCP传输（推荐）**

在旧服务器上：
```bash
cd /home/ubuntu/project/dys

# 打包数据库和上传文件
tar -czf dys_data.tar.gz backend/instance uploads/

# 传输到新服务器
scp dys_data.tar.gz root@111.228.59.77:/home/project/dys/
```

在新服务器上：
```bash
cd /home/project/dys

# 解压数据
tar -xzf dys_data.tar.gz

# 设置权限
chmod -R 755 backend/instance
chmod -R 755 uploads/
```

**方法B: 使用rsync同步（更快）**

在新服务器上：
```bash
cd /home/project/dys

# 同步数据库
rsync -avz root@119.91.214.94:/home/ubuntu/project/dys/backend/instance/ ./backend/instance/

# 同步上传文件
rsync -avz root@119.91.214.94:/home/ubuntu/project/dys/uploads/ ./uploads/
```

**方法C: 仅迁移数据库（手动重建上传文件）**

在旧服务器上：
```bash
cd /home/ubuntu/project/dys/backend/instance

# 下载数据库文件
# 方式1: 使用SCP
scp recruitment.db root@111.228.59.77:/home/project/dys/backend/instance/

# 方式2: 使用云盘中转（如果两台服务器网络不通）
# 先下载到本地，再上传到新服务器
```

### 步骤4: 配置防火墙

```bash
# 安装ufw
apt install -y ufw

# 开放必要端口
ufw allow 22/tcp    # SSH
ufw allow 5000/tcp  # 公共页面
ufw allow 5001/tcp  # 管理后台

# 启用防火墙
ufw enable

# 查看状态
ufw status
```

### 步骤5: 启动服务

```bash
cd /home/project/dys

# 赋予执行权限
chmod +x start_optimized.sh

# 启动服务
./start_optimized.sh
```

---

## ✅ 迁移验证清单

### 1. 检查服务状态
```bash
# 查看进程
ps aux | grep gunicorn

# 查看端口
netstat -tlnp | grep -E '5000|5001'

# 查看日志
tail -f /home/project/dys/backend/logs/access_5000.log
tail -f /home/project/dys/backend/logs/error_5000.log
```

### 2. 测试访问

**在本地浏览器测试：**
- 公共页面: http://111.228.59.77:5000/
- 管理后台: http://111.228.59.77:5001/

**测试登录：**
- 用户名: admin
- 密码: admin123（或你修改后的密码）

### 3. 验证数据完整性

```bash
# 进入数据库检查
cd /home/project/dys/backend
python3 -c "
from models.models import db, Job, Application, User
from app import app

with app.app_context():
    print(f'职位数量: {Job.query.count()}')
    print(f'简历数量: {Application.query.count()}')
    print(f'用户数量: {User.query.count()}')
"
```

### 4. 测试功能

- [ ] 浏览职位列表
- [ ] 查看职位详情
- [ ] 投递简历（测试上传功能）
- [ ] 管理后台登录
- [ ] 查看简历列表
- [ ] 下载简历文件

---

## 🔧 常见问题解决

### 问题1: 端口被占用
```bash
# 查看占用端口的进程
lsof -i :5000
lsof -i :5001

# 杀死进程
kill -9 <PID>
```

### 问题2: 权限错误
```bash
# 修复文件权限
cd /home/project/dys
chmod -R 755 .
chown -R root:root .

# 确保日志目录可写
mkdir -p backend/logs
chmod 777 backend/logs
```

### 问题3: 数据库文件损坏
```bash
# 检查数据库完整性
cd backend/instance
sqlite3 recruitment.db "PRAGMA integrity_check;"

# 如果损坏，从备份恢复
cp recruitment.db.backup recruitment.db
```

### 问题4: 依赖安装失败
```bash
# 使用国内镜像
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ flask flask-cors flask-sqlalchemy

# 或使用清华镜像
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple flask flask-cors flask-sqlalchemy
```

### 问题5: gevent安装失败
```bash
# 安装编译工具
apt install -y build-essential python3-dev

# 重新安装
pip3 install gevent zope.event greenlet

# 如果还是失败，使用标准worker
# 编辑启动脚本，去掉 -k gevent 参数
```

---

## 🔒 安全加固（迁移完成后）

### 1. 修改SSH端口（可选）
```bash
# 编辑SSH配置
nano /etc/ssh/sshd_config

# 修改端口（例如改为2222）
Port 2222

# 重启SSH
systemctl restart sshd

# 记得在防火墙开放新端口
ufw allow 2222/tcp
```

### 2. 禁用root密码登录（使用密钥）
```bash
# 在本地生成SSH密钥
ssh-keygen -t rsa -b 4096

# 上传公钥到服务器
ssh-copy-id root@111.228.59.77

# 禁用密码登录
nano /etc/ssh/sshd_config
# 设置: PasswordAuthentication no
systemctl restart sshd
```

### 3. 修改应用默认密码
```bash
# 登录管理后台
# 访问: http://111.228.59.77:5001/
# 用户名: admin
# 密码: admin123

# 在"个人中心"或"密码修改"页面修改密码
```

### 4. 修改SECRET_KEY
```bash
# 生成新的密钥
python3 -c "import secrets; print(secrets.token_hex(32))"

# 编辑配置文件
cd /home/project/dys/backend
nano app.py
# 修改: app.config['SECRET_KEY'] = '生成的新密钥'

nano admin_app.py
# 修改: admin_app.config['SECRET_KEY'] = '生成的新密钥'

# 重启服务
```

---

## 📊 性能优化（可选）

### 查看新服务器配置
```bash
# 查看CPU核心数
nproc

# 查看内存
free -h

# 查看磁盘IO性能
dd if=/dev/zero of=test bs=1M count=1024
```

### 根据配置选择启动脚本

**如果新服务器是 4核3.7GB：**
```bash
./start_optimized.sh
```

**如果新服务器是 4核16GB：**
```bash
./start_optimized_16g.sh
```

**如果新服务器是 8核16GB以上：**
```bash
# 需要调整worker数量
# 编辑启动脚本，增加worker数量
# 推荐: (CPU核心数 × 2) + 1
```

---

## 🔄 迁移后清理旧服务器

### 在确认新服务器运行正常后

```bash
# 1. 备份旧服务器数据（保留7天）
cd /home/ubuntu/project/dys
tar -czf dys_final_backup_$(date +%Y%m%d).tar.gz .

# 2. 停止旧服务器服务
./start_all_uv.sh stop

# 3. 可选：删除项目文件（谨慎操作）
# cd /home/ubuntu/project
# rm -rf dys

# 4. 更新DNS或防火墙规则
# 将域名指向新IP: 111.228.59.77
```

---

## 📝 迁移检查清单

### 迁移前
- [ ] 备份旧服务器所有数据
- [ ] 记录旧服务器配置（CPU、内存、磁盘）
- [ ] 导出数据库
- [ ] 打包上传文件
- [ ] 记录所有自定义配置

### 迁移中
- [ ] 修改新服务器初始密码
- [ ] 安装Python和依赖
- [ ] 克隆项目代码
- [ ] 传输数据库和文件
- [ ] 配置防火墙
- [ ] 启动服务

### 迁移后
- [ ] 验证服务运行正常
- [ ] 测试所有功能
- [ ] 检查数据完整性
- [ ] 修改默认密码和密钥
- [ ] 配置自动备份
- [ ] 更新DNS记录
- [ ] 监控系统运行24小时
- [ ] 备份旧服务器数据

---

## 🆘 紧急回滚

如果新服务器出现问题，可以立即回滚到旧服务器：

```bash
# 在旧服务器上重新启动服务
cd /home/ubuntu/project/dys
./start_all_uv.sh

# 将域名或访问地址改回旧IP: 119.91.214.94
```

---

## 📞 技术支持

迁移过程中遇到问题：
1. 查看日志文件定位错误
2. 检查防火墙和端口配置
3. 验证文件权限
4. 确认依赖完整安装

**常用命令：**
```bash
# 查看实时日志
tail -f backend/logs/error_5000.log

# 检查服务状态
systemctl status recruitment

# 重启服务
./start_all_uv.sh stop
./start_optimized.sh
```

---

## 🎉 迁移完成

迁移成功后，新服务器访问地址：
- **公共求职页面**: http://111.228.59.77:5000/
- **管理后台**: http://111.228.59.77:5001/

建议配置域名后使用：
- 公共页面: http://your-domain.com
- 管理后台: http://admin.your-domain.com

祝迁移顺利！
