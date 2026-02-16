#!/bin/bash

echo "========================================"
echo "招聘系统 - 优化版启动（适用于4核3.7GB服务器）"
echo "========================================"
echo

# 检查Python
if ! command -v python3 &> /dev/null; then
    echo "错误: 未找到 Python3"
    exit 1
fi

# 导航到backend目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/backend"

# 检查并安装依赖
echo "检查依赖..."
if ! python3 -c "import gevent" 2>/dev/null; then
    echo "安装 gevent（异步性能优化）..."
    pip3 install gevent
fi

if ! command -v gunicorn &> /dev/null; then
    echo "安装 gunicorn..."
    pip3 install gunicorn
fi

# 初始化数据库
echo "初始化数据库..."
python3 -c "from app import init_db; init_db()"

echo
echo "========================================"
echo "服务器配置信息"
echo "========================================"
echo "CPU核心: 4核"
echo "内存: 3.7GB"
echo "优化方案: Gevent异步模式"
echo "Worker数量: 6个（针对4核优化）"
echo "每个Worker连接数: 50"
echo "理论最大并发: 300个连接"
echo "实际推荐并发: 20-30人"
echo "========================================"
echo
echo "访问地址:"
echo "- 公共求职页面: http://your-server-ip:5000/"
echo "- 管理后台: http://your-server-ip:5001/"
echo
echo "默认账号: admin / admin123"
echo "重要: 首次登录后请立即修改密码！"
echo
echo "按 Ctrl+C 停止服务"
echo "========================================"
echo

# 启动公共服务（5000端口）- 后台运行
echo "启动公共服务 (端口 5000)..."
gunicorn -w 6 \
    -k gevent \
    --worker-connections 50 \
    -b 0.0.0.0:5000 \
    --access-logfile logs/access_5000.log \
    --error-logfile logs/error_5000.log \
    --daemon \
    --pid /tmp/recruitment_5000.pid \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    app:app

if [ $? -eq 0 ]; then
    echo "✓ 公共服务启动成功 (PID: $(cat /tmp/recruitment_5000.pid))"
else
    echo "✗ 公共服务启动失败"
    exit 1
fi

# 等待2秒
sleep 2

# 启动管理后台（5001端口）- 前台运行
echo "启动管理后台 (端口 5001)..."
echo "日志输出到终端，按 Ctrl+C 停止所有服务"
echo

# 捕获退出信号，清理后台进程
trap "echo '正在停止服务...'; kill \$(cat /tmp/recruitment_5000.pid 2>/dev/null); rm -f /tmp/recruitment_5000.pid; echo '所有服务已停止'; exit 0" INT TERM

gunicorn -w 4 \
    -k gevent \
    --worker-connections 30 \
    -b 0.0.0.0:5001 \
    --access-logfile - \
    --error-logfile - \
    --timeout 120 \
    --max-requests 1000 \
    --max-requests-jitter 50 \
    admin_app:admin_app
