# 云服务器部署指南

## 快速部署步骤

### 1. 上传代码到服务器

将整个项目文件夹上传到服务器，例如：
```bash
/home/ubuntu/recruitment-system/
```

### 2. 安装依赖

```bash
cd /home/ubuntu/recruitment-system/backend
pip3 install -r requirements.txt
```

### 3. 初始化数据

```bash
# 初始化管理员账号和演示数据
python3 init_demo_data.py
```

### 4. 启动服务

#### 方法A: 开发环境快速测试
```bash
python3 app.py
```

#### 方法B: 生产环境部署（推荐）

使用 Gunicorn + Supervisor/Systemd

**安装 Gunicorn:**
```bash
pip3 install gunicorn
```

**启动服务:**
```bash
cd /home/ubuntu/recruitment-system/backend
gunicorn -w 4 -b 0.0.0.0:5000 app:app
```

### 5. 访问系统

在浏览器中访问：
- 外部页面: `http://your-server-ip:5000/`
- 管理后台: `http://your-server-ip:5000/admin`

---

## 生产环境配置

### 使用 Systemd 管理服务

创建服务文件 `/etc/systemd/system/recruitment.service`:

```ini
[Unit]
Description=Recruitment System
After=network.target

[Service]
Type=notify
User=ubuntu
WorkingDirectory=/home/ubuntu/recruitment-system/backend
Environment="PATH=/home/ubuntu/recruitment-system/backend/venv/bin"
ExecStart=/home/ubuntu/recruitment-system/backend/venv/bin/gunicorn -w 4 -b 0.0.0.0:5000 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

启动服务：
```bash
sudo systemctl daemon-reload
sudo systemctl start recruitment
sudo systemctl enable recruitment
sudo systemctl status recruitment
```

---

## 使用 Nginx 反向代理（推荐）

### 1. 安装 Nginx
```bash
sudo apt update
sudo apt install nginx
```

### 2. 配置 Nginx

创建配置文件 `/etc/nginx/sites-available/recruitment`:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名或IP

    client_max_body_size 16M;

    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # 静态文件缓存
    location /static {
        alias /home/ubuntu/recruitment-system/frontend;
        expires 30d;
    }

    # 上传文件
    location /uploads {
        alias /home/ubuntu/recruitment-system/uploads;
        expires 30d;
    }
}
```

启用配置：
```bash
sudo ln -s /etc/nginx/sites-available/recruitment /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 安全配置

### 1. 修改默认密钥

编辑 `backend/app.py`，修改：
```python
app.config['SECRET_KEY'] = 'your-very-secret-key-here-change-this'
```

生成随机密钥：
```python
import secrets
print(secrets.token_hex(32))
```

### 2. 修改管理员密码

首次登录后，在管理后台修改密码，或者删除数据库文件重新初始化：
```bash
rm backend/recruitment.db
python3 backend/init_demo_data.py
```

### 3. 配置防火墙

```bash
# 允许 HTTP 和 HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# 如果直接使用5000端口
sudo ufw allow 5000/tcp

sudo ufw enable
```

### 4. 启用 HTTPS（推荐）

使用 Let's Encrypt 免费 SSL 证书：

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d your-domain.com
```

---

## 数据库升级（可选）

### 迁移到 MySQL

1. 安装 MySQL 客户端库：
```bash
pip3 install pymysql
```

2. 修改 `app.py` 配置：
```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://username:password@localhost/recruitment_db'
```

3. 创建数据库：
```sql
CREATE DATABASE recruitment_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 迁移到 PostgreSQL

1. 安装客户端库：
```bash
pip3 install psycopg2-binary
```

2. 修改配置：
```python
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://username:password@localhost/recruitment_db'
```

---

## 监控和日志

### 查看服务日志
```bash
# Systemd 服务日志
sudo journalctl -u recruitment -f

# Nginx 日志
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### 性能监控
```bash
# 安装 htop
sudo apt install htop
htop

# 查看进程
ps aux | grep gunicorn
```

---

## 备份策略

### 自动备份脚本

创建 `/home/ubuntu/backup-recruitment.sh`:

```bash
#!/bin/bash
BACKUP_DIR="/home/ubuntu/backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p $BACKUP_DIR

# 备份数据库
cp /home/ubuntu/recruitment-system/backend/recruitment.db \
   $BACKUP_DIR/recruitment_$DATE.db

# 备份上传文件
tar -czf $BACKUP_DIR/uploads_$DATE.tar.gz \
   /home/ubuntu/recruitment-system/uploads/

# 只保留最近7天的备份
find $BACKUP_DIR -type f -mtime +7 -delete

echo "Backup completed: $DATE"
```

添加到定时任务：
```bash
chmod +x /home/ubuntu/backup-recruitment.sh
crontab -e

# 每天凌晨2点备份
0 2 * * * /home/ubuntu/backup-recruitment.sh
```

---

## 常见问题

### 端口被占用
```bash
# 查看端口占用
sudo lsof -i :5000
sudo netstat -tulpn | grep 5000

# 杀死进程
sudo kill -9 <PID>
```

### 权限问题
```bash
# 确保文件权限正确
sudo chown -R ubuntu:ubuntu /home/ubuntu/recruitment-system
chmod -R 755 /home/ubuntu/recruitment-system
```

### 数据库锁定
```bash
# SQLite 数据库被锁定时
sudo fuser -k backend/recruitment.db
```

---

## 性能优化

### Gunicorn 工作进程数
```bash
# 推荐: (2 × CPU核心数) + 1
# 例如 4核 CPU: (2 × 4) + 1 = 9
gunicorn -w 9 -b 0.0.0.0:5000 app:app
```

### 启用 Gzip 压缩

在 Nginx 配置中添加：
```nginx
gzip on;
gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
gzip_min_length 1000;
```

---

## 快速部署命令汇总

```bash
# 1. 上传代码并安装依赖
cd /home/ubuntu/recruitment-system/backend
pip3 install -r requirements.txt
pip3 install gunicorn

# 2. 初始化数据
python3 init_demo_data.py

# 3. 修改配置（SECRET_KEY）
nano app.py

# 4. 启动服务（测试）
gunicorn -w 4 -b 0.0.0.0:5000 app:app

# 5. 配置 Systemd（生产环境）
sudo nano /etc/systemd/system/recruitment.service
sudo systemctl daemon-reload
sudo systemctl start recruitment
sudo systemctl enable recruitment

# 6. 配置 Nginx（可选）
sudo apt install nginx
sudo nano /etc/nginx/sites-available/recruitment
sudo ln -s /etc/nginx/sites-available/recruitment /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx

# 7. 配置防火墙
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

---

## 访问地址

部署完成后：
- **外部求职页面**: http://your-server-ip/
- **管理后台**: http://your-server-ip/admin
- **API健康检查**: http://your-server-ip/api/health

默认账号: admin / admin123

**重要**: 首次登录后请立即修改管理员密码！
