#!/bin/bash

echo "========================================"
echo "招聘系统 - 16GB服务器优化版启动"
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
    echo "安装 gevent 和相关依赖（异步性能优化）..."
    pip3 install 'gevent>=24.0.0' 'zope.event>=5.0' 'greenlet>=3.0.0'
fi

if ! command -v gunicorn &> /dev/null; then
    echo "安装 gunicorn..."
    pip3 install gunicorn
fi

# 验证 gevent 是否可用
if ! python3 -c "import gevent; from gevent import monkey" 2>/dev/null; then
    echo "错误: gevent 安装失败或不兼容"
    echo "尝试使用标准worker模式启动（性能稍低）..."
    USE_GEVENT=false
else
    USE_GEVENT=true
fi

# 初始化数据库
echo "初始化数据库..."
python3 -c "from app import init_db; init_db()"

# 创建日志目录
mkdir -p logs

echo
echo "========================================"
echo "服务器配置信息"
echo "========================================"
echo "CPU核心: 4核"
echo "内存: 16GB"
echo "优化方案: Gevent异步模式 + 大内存优化"
echo "公共服务Worker: 20个"
echo "管理后台Worker: 10个"
echo "每个Worker连接数: 100"
echo "理论最大并发: 2500个连接"
echo "实际推荐并发: 60-80人（优化脚本+SQLite）"
echo "            150-200人（升级MySQL后）"
echo "========================================"
echo
echo "访问地址:"
echo "- 公共求职页面: http://your-server-ip:5000/"
echo "- 管理后台: http://your-server-ip:5001/"
echo
echo "默认账号: admin / admin123"
echo "重要: 首次登录后请立即修改密码！"
echo
echo "性能提示:"
echo "1. 当前使用SQLite，建议升级到MySQL以获得更好性能"
echo "2. 建议使用腾讯云COS存储简历文件，解决带宽瓶颈"
echo "3. 建议配置Nginx反向代理和缓存"
echo "详见: README_PERFORMANCE.md"
echo
echo "按 Ctrl+C 停止所有服务"
echo "========================================"
echo

# 启动公共服务（5000端口）- 后台运行
echo "启动公共服务 (端口 5000)..."
if [ "$USE_GEVENT" = true ]; then
    gunicorn -w 20 \
        -k gevent \
        --worker-connections 100 \
        -b 0.0.0.0:5000 \
        --access-logfile logs/access_5000.log \
        --error-logfile logs/error_5000.log \
        --daemon \
        --pid /tmp/recruitment_5000.pid \
        --timeout 120 \
        --max-requests 5000 \
        --max-requests-jitter 100 \
        --worker-tmp-dir /dev/shm \
        app:app
else
    gunicorn -w 16 \
        -b 0.0.0.0:5000 \
        --access-logfile logs/access_5000.log \
        --error-logfile logs/error_5000.log \
        --daemon \
        --pid /tmp/recruitment_5000.pid \
        --timeout 120 \
        --max-requests 5000 \
        --max-requests-jitter 100 \
        --worker-tmp-dir /dev/shm \
        app:app
fi

if [ $? -eq 0 ]; then
    echo "✓ 公共服务启动成功 (PID: $(cat /tmp/recruitment_5000.pid))"
    echo "  - Workers: 20个"
    echo "  - 最大连接: 2000"
    echo "  - 日志: logs/access_5000.log"
else
    echo "✗ 公共服务启动失败"
    exit 1
fi

# 等待2秒
sleep 2

# 启动管理后台（5001端口）- 前台运行
echo "启动管理后台 (端口 5001)..."
echo "  - Workers: 10个"
echo "  - 最大连接: 500"
echo "日志输出到终端，按 Ctrl+C 停止所有服务"
echo

# 捕获退出信号，清理后台进程
trap "echo ''; echo '正在停止服务...'; kill \$(cat /tmp/recruitment_5000.pid 2>/dev/null); rm -f /tmp/recruitment_5000.pid; echo '所有服务已停止'; exit 0" INT TERM

if [ "$USE_GEVENT" = true ]; then
    gunicorn -w 10 \
        -k gevent \
        --worker-connections 50 \
        -b 0.0.0.0:5001 \
        --access-logfile - \
        --error-logfile - \
        --timeout 120 \
        --max-requests 5000 \
        --max-requests-jitter 100 \
        --worker-tmp-dir /dev/shm \
        admin_app:admin_app
else
    gunicorn -w 8 \
        -b 0.0.0.0:5001 \
        --access-logfile - \
        --error-logfile - \
        --timeout 120 \
        --max-requests 5000 \
        --max-requests-jitter 100 \
        --worker-tmp-dir /dev/shm \
        admin_app:admin_app
fi
