#!/bin/bash

echo "========================================"
echo "京东云服务器 - 一键部署脚本"
echo "========================================"
echo

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    echo "错误: 请使用root用户运行此脚本"
    echo "使用命令: sudo bash deploy_new_server.sh"
    exit 1
fi

# 检查网络连接
echo "检查网络连接..."
if ! ping -c 1 github.com &> /dev/null; then
    echo "警告: 无法连接到GitHub，将使用备用方案"
    USE_BACKUP=true
else
    USE_BACKUP=false
fi

# 更新系统
echo
echo "[1/8] 更新系统软件包..."
apt update && apt upgrade -y

# 安装基础工具
echo
echo "[2/8] 安装基础工具..."
apt install -y python3 python3-pip git curl wget build-essential python3-dev
apt install -y ufw net-tools htop sqlite3

# 安装uv（可选，推荐）
echo
echo "[3/8] 安装uv包管理器（推荐）..."
if ! command -v uv &> /dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source $HOME/.cargo/env
    echo "✓ uv 安装成功"
else
    echo "✓ uv 已安装"
fi

# 创建项目目录
echo
echo "[4/8] 创建项目目录..."
mkdir -p /home/project
cd /home/project

# 克隆项目或下载
echo
echo "[5/8] 获取项目代码..."
if [ "$USE_BACKUP" = true ]; then
    # 使用备用下载方式
    echo "从备用源下载项目..."
    wget https://codeload.github.com/tanstardream/dys/zip/refs/heads/main -O dys.zip
    apt install -y unzip
    unzip dys.zip
    mv dys-main dys
    rm dys.zip
else
    # 正常从GitHub克隆
    if [ -d "dys" ]; then
        echo "项目目录已存在，更新代码..."
        cd dys
        git pull
        cd ..
    else
        git clone https://github.com/tanstardream/dys.git
    fi
fi

cd /home/project/dys

# 安装Python依赖
echo
echo "[6/8] 安装Python依赖..."
cd backend

# 使用国内镜像加速
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ \
    flask>=3.0.0 \
    flask-cors>=4.0.0 \
    flask-sqlalchemy>=3.1.0 \
    pyjwt>=2.8.0 \
    python-docx>=1.1.0 \
    werkzeug>=3.0.0 \
    gunicorn>=25.0.0

# 安装gevent（性能优化）
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ \
    'gevent>=24.0.0' \
    'zope.event>=5.0' \
    'greenlet>=3.0.0'

cd ..

# 配置防火墙
echo
echo "[7/8] 配置防火墙..."
ufw --force enable
ufw allow 22/tcp    # SSH
ufw allow 5000/tcp  # 公共页面
ufw allow 5001/tcp  # 管理后台
ufw status

# 初始化数据库
echo
echo "[8/8] 初始化数据库..."
cd backend
python3 -c "from app import init_db; init_db()"
cd ..

# 创建必要目录
mkdir -p backend/logs
mkdir -p uploads
chmod -R 755 backend/logs
chmod -R 755 uploads

echo
echo "========================================"
echo "部署完成！"
echo "========================================"
echo
echo "下一步操作："
echo
echo "1. 如果有旧数据需要迁移，请执行："
echo "   方法A - 从旧服务器直接同步："
echo "   rsync -avz OLD_SERVER_IP:/path/to/dys/backend/instance/ ./backend/instance/"
echo "   rsync -avz OLD_SERVER_IP:/path/to/dys/uploads/ ./uploads/"
echo
echo "   方法B - 使用备份文件："
echo "   tar -xzf dys_backup.tar.gz"
echo
echo "2. 启动服务："
echo "   cd /home/project/dys"
echo "   chmod +x start_optimized.sh"
echo "   ./start_optimized.sh"
echo
echo "3. 访问地址："
echo "   公共页面: http://$(curl -s ifconfig.me):5000/"
echo "   管理后台: http://$(curl -s ifconfig.me):5001/"
echo
echo "4. 默认管理员账号："
echo "   用户名: admin"
echo "   密码: admin123"
echo "   ⚠️  请立即登录后修改密码！"
echo
echo "5. 查看服务器配置："
echo "   CPU: $(nproc) 核"
echo "   内存: $(free -h | awk '/^Mem:/ {print $2}')"
echo "   磁盘: $(df -h / | awk 'NR==2 {print $2}')"
echo
echo "6. 如果是16GB内存服务器，使用优化脚本："
echo "   ./start_optimized_16g.sh"
echo
echo "========================================"
echo "安全提示："
echo "1. 修改root密码: passwd"
echo "2. 修改应用SECRET_KEY（编辑 backend/app.py）"
echo "3. 修改管理员密码（登录后台修改）"
echo "4. 配置自动备份"
echo "========================================"
echo
