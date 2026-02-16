# 快速迁移指令 - 腾讯云 → 京东云

## 🚀 5分钟快速迁移

### 新服务器信息
- **IP**: 111.228.59.77
- **用户**: root
- **初始密码**: degKpSS（请立即修改）

---

## 步骤1: 连接新服务器并修改密码（1分钟）

```bash
# 在你的电脑上执行
ssh root@111.228.59.77
# 输入初始密码: degKpSS

# 修改密码（必须）
passwd
# 输入两次新密码

# 查看服务器配置
free -h          # 查看内存
nproc            # 查看CPU核心数
df -h            # 查看磁盘
```

---

## 步骤2: 一键部署环境（2分钟）

```bash
# 在新服务器上执行
wget https://raw.githubusercontent.com/tanstardream/dys/main/deploy_new_server.sh
chmod +x deploy_new_server.sh
./deploy_new_server.sh

# 脚本会自动：
# ✓ 更新系统
# ✓ 安装Python和依赖
# ✓ 克隆项目代码
# ✓ 安装应用依赖
# ✓ 配置防火墙
# ✓ 初始化数据库
```

---

## 步骤3: 迁移数据（2分钟）

### 方法A: 直接从旧服务器同步（推荐）

```bash
# 在新服务器上执行
cd /home/project/dys

# 同步数据库
rsync -avz root@119.91.214.94:/home/ubuntu/project/dys/backend/instance/ ./backend/instance/

# 同步上传文件
rsync -avz root@119.91.214.94:/home/ubuntu/project/dys/uploads/ ./uploads/
```

### 方法B: 使用备份文件

**在旧服务器（腾讯云）上：**
```bash
cd /home/ubuntu/project/dys
wget https://raw.githubusercontent.com/tanstardream/dys/main/backup_for_migration.sh
chmod +x backup_for_migration.sh
./backup_for_migration.sh

# 会生成文件: dys_backup_YYYYMMDD_HHMMSS.tar.gz
# 传输到新服务器
scp dys_backup_*.tar.gz root@111.228.59.77:/home/project/dys/
```

**在新服务器（京东云）上：**
```bash
cd /home/project/dys

# 解压备份
tar -xzf dys_backup_*.tar.gz

# 移动文件到正确位置
mv dys_backup_*/backend/instance ./backend/
mv dys_backup_*/uploads ./

# 清理
rm -rf dys_backup_*
```

---

## 步骤4: 启动服务（30秒）

```bash
cd /home/project/dys

# 赋予执行权限
chmod +x start_optimized.sh

# 启动服务
./start_optimized.sh

# 按 Ctrl+C 可以停止服务
# 如果需要后台运行，使用 nohup:
# nohup ./start_optimized.sh > /dev/null 2>&1 &
```

---

## 步骤5: 验证访问（30秒）

打开浏览器访问：

- **公共求职页面**: http://111.228.59.77:5000/
- **管理后台**: http://111.228.59.77:5001/

**登录测试：**
- 用户名: `admin`
- 密码: `admin123`（或你之前修改的密码）

**验证功能：**
- [ ] 查看职位列表
- [ ] 浏览职位详情
- [ ] 测试投递简历
- [ ] 管理后台登录
- [ ] 查看简历数据

---

## ✅ 迁移完成检查

```bash
# 查看服务状态
ps aux | grep gunicorn

# 查看端口监听
netstat -tlnp | grep -E '5000|5001'

# 查看日志
tail -f /home/project/dys/backend/logs/access_5000.log

# 验证数据完整性
cd /home/project/dys/backend
python3 -c "
from models.models import db, Job, Application, User
from app import app
with app.app_context():
    print(f'职位: {Job.query.count()}')
    print(f'简历: {Application.query.count()}')
    print(f'用户: {User.query.count()}')
"
```

---

## 🔒 安全加固（必须）

### 1. 修改应用SECRET_KEY

```bash
# 生成新密钥
python3 -c "import secrets; print(secrets.token_hex(32))"

# 编辑配置
nano /home/project/dys/backend/app.py
# 修改第22行: app.config['SECRET_KEY'] = '新生成的密钥'

nano /home/project/dys/backend/admin_app.py
# 修改第28行: admin_app.config['SECRET_KEY'] = '新生成的密钥'

# 重启服务
pkill -f gunicorn
./start_optimized.sh
```

### 2. 修改管理员密码

访问: http://111.228.59.77:5001/
登录后在"个人中心"修改密码

### 3. 配置SSH密钥登录（可选）

```bash
# 在你的电脑上
ssh-keygen -t rsa -b 4096
ssh-copy-id root@111.228.59.77

# 在服务器上禁用密码登录
nano /etc/ssh/sshd_config
# 设置: PasswordAuthentication no
systemctl restart sshd
```

---

## 🔄 后续操作

### 性能优化（如果新服务器是16GB内存）

```bash
cd /home/project/dys
pkill -f gunicorn
./start_optimized_16g.sh
```

### 配置域名（推荐）

1. 在域名DNS管理中添加A记录：
   - 主机记录: `@` 或 `www`
   - 记录值: `111.228.59.77`
   - TTL: 600

2. 等待DNS生效（5-30分钟）

3. 访问: http://your-domain.com:5000/

### 配置Nginx反向代理（去掉端口号）

```bash
apt install -y nginx

cat > /etc/nginx/sites-available/recruitment <<'EOF'
server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }

    location /admin {
        proxy_pass http://127.0.0.1:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
EOF

ln -s /etc/nginx/sites-available/recruitment /etc/nginx/sites-enabled/
nginx -t
systemctl restart nginx

# 开放80端口
ufw allow 80/tcp
```

访问: http://your-domain.com （无需端口号）

### 配置自动备份

```bash
# 创建备份脚本
cat > /root/backup_daily.sh <<'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d)
BACKUP_DIR="/root/backups"
mkdir -p $BACKUP_DIR

# 备份数据库
cp /home/project/dys/backend/instance/recruitment.db \
   $BACKUP_DIR/recruitment_${DATE}.db

# 备份上传文件
tar -czf $BACKUP_DIR/uploads_${DATE}.tar.gz \
   /home/project/dys/uploads/

# 只保留最近7天
find $BACKUP_DIR -type f -mtime +7 -delete
EOF

chmod +x /root/backup_daily.sh

# 添加到定时任务
crontab -e
# 添加: 0 2 * * * /root/backup_daily.sh
```

---

## 🆘 常见问题

### Q: 服务启动失败怎么办？

```bash
# 查看错误日志
tail -50 /home/project/dys/backend/logs/error_5000.log

# 检查端口占用
lsof -i :5000
lsof -i :5001

# 杀死占用进程
pkill -f gunicorn

# 重新启动
./start_optimized.sh
```

### Q: 访问不了怎么办？

```bash
# 检查防火墙
ufw status

# 确保端口开放
ufw allow 5000/tcp
ufw allow 5001/tcp

# 检查服务是否运行
ps aux | grep gunicorn
```

### Q: 数据没有迁移过来？

```bash
# 检查数据库文件
ls -lh /home/project/dys/backend/instance/

# 如果没有，重新同步
rsync -avz root@119.91.214.94:/home/ubuntu/project/dys/backend/instance/ /home/project/dys/backend/instance/
```

---

## 📞 紧急回滚

如果新服务器有问题，立即切回旧服务器：

```bash
# 在旧服务器（119.91.214.94）上
cd /home/ubuntu/project/dys
./start_all_uv.sh

# 将访问地址改回旧IP
```

---

## 📋 迁移清单

- [ ] 连接新服务器并修改初始密码
- [ ] 运行一键部署脚本
- [ ] 迁移数据库和上传文件
- [ ] 启动服务
- [ ] 验证功能正常
- [ ] 修改SECRET_KEY
- [ ] 修改管理员密码
- [ ] 配置防火墙
- [ ] （可选）配置域名
- [ ] （可选）配置Nginx
- [ ] （可选）配置自动备份
- [ ] 监控运行24小时
- [ ] 备份旧服务器数据
- [ ] 关闭旧服务器

---

## 🎉 迁移成功

新服务器访问地址：
- **公共页面**: http://111.228.59.77:5000/
- **管理后台**: http://111.228.59.77:5001/

祝使用愉快！
