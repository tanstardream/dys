# 性能优化指南 - 针对4核3.7GB服务器

## 📊 服务器配置
- **CPU**: 4核 Intel Xeon @ 2.5GHz
- **内存**: 3.63 GiB
- **磁盘**: 39 GB (4K写入 1770 IOPS)
- **网络**: 下载 100+ Mbps, 上传 2.6 Mbps
- **平台**: 腾讯云广州

---

## 🎯 并发能力评估

| 配置方案 | 并发用户 | 内存占用 | 说明 |
|---------|---------|---------|------|
| 当前配置（开发模式） | 1-2人 | ~200MB | Flask内置服务器，仅供测试 |
| 标准生产（4 workers） | 10-15人 | ~600MB | start_production.sh |
| **优化配置（推荐）** | **20-30人** | **~800MB** | start_optimized.sh |
| 升级MySQL | 50-100人 | ~1GB | 需要数据库迁移 |

---

## ⚡ 快速启动优化配置

### 1. 使用优化脚本（推荐）

```bash
# 赋予执行权限
chmod +x start_optimized.sh

# 启动服务
./start_optimized.sh
```

**优化内容：**
- ✅ 使用 Gevent 异步worker（大幅提升并发）
- ✅ 6个公共服务 workers（平衡性能与内存）
- ✅ 4个管理后台 workers（管理访问较少）
- ✅ 每个worker支持50个并发连接
- ✅ 自动重启（max-requests防止内存泄漏）
- ✅ 分离日志文件

---

## 🔧 手动优化配置

### 方案1: Gevent异步模式（不改数据库）

**安装依赖：**
```bash
pip3 install gunicorn gevent
```

**启动公共服务（5000端口）：**
```bash
cd backend
gunicorn -w 6 -k gevent --worker-connections 50 \
    -b 0.0.0.0:5000 \
    --timeout 120 \
    --max-requests 1000 \
    app:app
```

**启动管理后台（5001端口）：**
```bash
# 新开一个终端
cd backend
gunicorn -w 4 -k gevent --worker-connections 30 \
    -b 0.0.0.0:5001 \
    --timeout 120 \
    --max-requests 1000 \
    admin_app:admin_app
```

**性能提升：**
- 理论并发: 6×50 + 4×30 = 420个连接
- 实际用户: 20-30人（考虑资源限制）
- 内存占用: ~800MB（比标准方案多200MB，但并发提升2倍）

---

## 📈 进一步优化建议

### 1. 升级到MySQL（适合>30人使用）

**当前瓶颈：**
```python
# backend/app.py:23
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///recruitment.db'
```

SQLite限制：
- ❌ 同时只能1个写入操作
- ❌ 多用户投递简历会排队
- ❌ 管理操作会阻塞用户访问

**迁移到MySQL：**

```bash
# 1. 安装MySQL
sudo apt install mysql-server python3-pymysql

# 2. 创建数据库
mysql -u root -p
CREATE DATABASE recruitment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'recruitment_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON recruitment.* TO 'recruitment_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 3. 安装Python依赖
pip3 install pymysql

# 4. 修改配置（app.py 和 admin_app.py）
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://recruitment_user:your_password@localhost/recruitment'
```

**性能提升：**
- 支持真正的并发写入
- 可承载 50-100 人同时使用
- 更好的数据完整性

---

### 2. 优化简历文件处理

**当前限制：**
```python
# backend/app.py:26
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16MB
```

**优化建议：**

1. **减小文件大小限制（节省带宽）：**
```python
app.config['MAX_CONTENT_LENGTH'] = 5 * 1024 * 1024  # 5MB
```

2. **压缩上传文件：**
```bash
pip3 install pillow  # 图片压缩
```

3. **使用对象存储（腾讯云COS）：**
```bash
pip3 install cos-python-sdk-v5

# 优点：
# - 不占用服务器磁盘
# - 上传下载速度更快
# - 节省服务器带宽
```

---

### 3. 添加Nginx反向代理

**优势：**
- ✅ 静态文件缓存（减少Python负载）
- ✅ Gzip压缩（节省50%+带宽）
- ✅ 负载均衡（可多实例部署）
- ✅ SSL/HTTPS支持

**配置示例：**
```nginx
# /etc/nginx/sites-available/recruitment
server {
    listen 80;
    server_name your-domain.com;

    client_max_body_size 5M;

    # Gzip压缩
    gzip on;
    gzip_types text/css application/json application/javascript;
    gzip_min_length 1000;

    # 公共服务
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_buffering on;
        proxy_cache_valid 200 5m;  # 缓存5分钟
    }

    # 管理后台（可限制IP访问）
    location /admin {
        proxy_pass http://127.0.0.1:5001;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        # 可选：只允许特定IP访问
        # allow 1.2.3.4;
        # deny all;
    }

    # 静态文件直接服务
    location /static/ {
        alias /path/to/frontend/;
        expires 30d;
        add_header Cache-Control "public, immutable";
    }
}
```

启用：
```bash
sudo ln -s /etc/nginx/sites-available/recruitment /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

---

## 🛡️ 安全优化

### 1. 限制管理后台访问

**只允许内网访问5001端口：**
```bash
# backend/admin_app.py:97
admin_app.run(debug=False, host='127.0.0.1', port=5001)  # 改为127.0.0.1
```

然后通过Nginx或SSH隧道访问：
```bash
# SSH隧道方式
ssh -L 5001:localhost:5001 user@your-server-ip
# 然后在本地浏览器访问 http://localhost:5001
```

### 2. 添加请求频率限制

```bash
pip3 install flask-limiter
```

```python
# backend/app.py
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    app=app,
    key_func=get_remote_address,
    default_limits=["200 per day", "50 per hour"]
)

# 限制投递简历频率
@limiter.limit("5 per hour")
@app.route('/api/applications', methods=['POST'])
def submit_application():
    # ...
```

---

## 📊 监控和调优

### 1. 实时监控资源使用

```bash
# 安装htop
sudo apt install htop
htop

# 查看Gunicorn进程
ps aux | grep gunicorn

# 查看内存使用
free -h

# 查看磁盘IO
iostat -x 1
```

### 2. 日志分析

```bash
# 查看访问日志
tail -f backend/logs/access_5000.log

# 统计请求量
grep "POST /api/applications" backend/logs/access_5000.log | wc -l

# 查看错误日志
tail -f backend/logs/error_5000.log
```

### 3. 性能基准测试

```bash
# 安装ab测试工具
sudo apt install apache2-utils

# 测试首页
ab -n 1000 -c 10 http://localhost:5000/

# 测试API
ab -n 100 -c 5 -p data.json -T application/json http://localhost:5000/api/jobs
```

---

## 🚨 关键瓶颈排序

根据你的服务器配置，瓶颈优先级：

1. **🔴 上传带宽（2.6 Mbps）** - 最严重
   - 影响：简历下载速度
   - 解决：使用腾讯云COS对象存储

2. **🟡 SQLite数据库** - 中等
   - 影响：并发写入性能
   - 解决：升级MySQL

3. **🟡 磁盘IO（1770 IOPS）** - 中等
   - 影响：文件上传/下载
   - 解决：使用SSD云盘或对象存储

4. **🟢 内存（3.7GB）** - 可接受
   - 影响：Worker数量限制
   - 当前配置足够20-30人使用

5. **🟢 CPU（4核）** - 可接受
   - 影响：计算密集型任务
   - Web应用CPU占用不高

---

## 💰 成本效益分析

| 优化方案 | 成本 | 效果 | 难度 | 推荐度 |
|---------|-----|------|------|--------|
| Gevent异步 | 免费 | 并发+100% | ⭐ | ⭐⭐⭐⭐⭐ |
| Nginx缓存 | 免费 | 响应速度+50% | ⭐⭐ | ⭐⭐⭐⭐ |
| 升级MySQL | 免费 | 并发+200% | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| 腾讯云COS | ~¥10/月 | 下载速度+500% | ⭐⭐ | ⭐⭐⭐⭐⭐ |
| 升级服务器 | ~¥100/月 | 全面提升 | ⭐ | ⭐⭐ |

---

## ✅ 推荐实施步骤

**第一阶段（立即实施）：**
1. ✅ 使用 `start_optimized.sh` 启动
2. ✅ 修改默认密码
3. ✅ 限制文件大小为5MB

**第二阶段（有用户后）：**
1. ✅ 配置Nginx反向代理
2. ✅ 添加请求频率限制
3. ✅ 启用HTTPS

**第三阶段（>20人使用）：**
1. ✅ 迁移到MySQL数据库
2. ✅ 使用腾讯云COS存储简历
3. ✅ 配置CDN加速

---

## 📞 常见问题

**Q: 如何知道当前有多少人在线？**
```bash
# 查看当前连接数
netstat -an | grep :5000 | grep ESTABLISHED | wc -l
```

**Q: 内存不足怎么办？**
```bash
# 减少worker数量
gunicorn -w 4 -k gevent --worker-connections 40 ...

# 添加Swap（临时方案）
sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
```

**Q: 如何平滑重启服务？**
```bash
# 获取主进程PID
cat /tmp/recruitment_5000.pid

# 发送HUP信号（平滑重启）
kill -HUP $(cat /tmp/recruitment_5000.pid)
```

---

## 🎯 总结

**当前配置适合场景：**
- ✅ 小型诊所/中医馆
- ✅ 日访问 < 100 人
- ✅ 同时在线 < 20 人
- ✅ 职位数量 < 50 个

**需要升级场景：**
- ❌ 连锁机构（多店铺）
- ❌ 日访问 > 500 人
- ❌ 需要大量简历下载
- ❌ 需要视频面试等高级功能

按照本指南优化后，你的服务器可以**稳定支持 20-30 人同时使用**，足够应对大部分小型企业的招聘需求。
