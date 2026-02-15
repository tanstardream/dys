#!/bin/bash
# 启动招聘系统的所有服务 - 标准Python版本
# 用法:
#   ./start_all.sh           # 后台运行（默认）
#   ./start_all.sh -f        # 前台运行显示日志
#   ./start_all.sh stop      # 停止所有服务
#   ./start_all.sh status    # 查看服务状态
#   ./start_all.sh restart   # 重启所有服务

set -e

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKEND_DIR="$PROJECT_DIR/backend"
LOG_DIR="$PROJECT_DIR/logs"
PID_DIR="$PROJECT_DIR/pids"

# 创建日志和PID目录
mkdir -p "$LOG_DIR"
mkdir -p "$PID_DIR"

PID_FILE_PUBLIC="$PID_DIR/public.pid"
PID_FILE_ADMIN="$PID_DIR/admin.pid"
LOG_FILE_PUBLIC="$LOG_DIR/public.log"
LOG_FILE_ADMIN="$LOG_DIR/admin.log"

# 停止服务
stop_services() {
    echo "正在停止服务..."

    if [ -f "$PID_FILE_PUBLIC" ]; then
        PID=$(cat "$PID_FILE_PUBLIC")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "  ✓ 公共服务已停止 (PID: $PID)"
        fi
        rm -f "$PID_FILE_PUBLIC"
    fi

    if [ -f "$PID_FILE_ADMIN" ]; then
        PID=$(cat "$PID_FILE_ADMIN")
        if kill -0 "$PID" 2>/dev/null; then
            kill "$PID"
            echo "  ✓ 管理服务已停止 (PID: $PID)"
        fi
        rm -f "$PID_FILE_ADMIN"
    fi

    # 确保进程被杀掉
    pkill -f "python app.py" 2>/dev/null || true
    pkill -f "python admin_app.py" 2>/dev/null || true

    echo "所有服务已停止"
}

# 查看状态
show_status() {
    echo "======================================"
    echo "服务状态"
    echo "======================================"

    if [ -f "$PID_FILE_PUBLIC" ]; then
        PID=$(cat "$PID_FILE_PUBLIC")
        if kill -0 "$PID" 2>/dev/null; then
            echo "✓ 公共服务运行中 (PID: $PID)"
            echo "  端口: 5000"
            echo "  日志: $LOG_FILE_PUBLIC"
        else
            echo "✗ 公共服务未运行 (PID文件存在但进程不存在)"
        fi
    else
        echo "✗ 公共服务未运行"
    fi

    echo ""

    if [ -f "$PID_FILE_ADMIN" ]; then
        PID=$(cat "$PID_FILE_ADMIN")
        if kill -0 "$PID" 2>/dev/null; then
            echo "✓ 管理服务运行中 (PID: $PID)"
            echo "  端口: 5001"
            echo "  日志: $LOG_FILE_ADMIN"
        else
            echo "✗ 管理服务未运行 (PID文件存在但进程不存在)"
        fi
    else
        echo "✗ 管理服务未运行"
    fi

    echo "======================================"
}

# 后台启动
start_background() {
    echo "======================================"
    echo "德元升中医馆 - 招聘管理系统"
    echo "======================================"
    echo ""
    echo "正在后台启动服务..."
    echo ""

    cd "$BACKEND_DIR"

    # 启动公共服务
    echo "[1/2] 启动公共页面服务 (端口 5000)..."
    nohup python app.py > "$LOG_FILE_PUBLIC" 2>&1 &
    echo $! > "$PID_FILE_PUBLIC"
    PUBLIC_PID=$!
    echo "  ✓ 已启动 (PID: $PUBLIC_PID)"

    sleep 2

    # 启动管理服务
    echo "[2/2] 启动管理后台服务 (端口 5001)..."
    nohup python admin_app.py > "$LOG_FILE_ADMIN" 2>&1 &
    echo $! > "$PID_FILE_ADMIN"
    ADMIN_PID=$!
    echo "  ✓ 已启动 (PID: $ADMIN_PID)"

    sleep 1

    echo ""
    echo "======================================"
    echo "服务启动完成！"
    echo "======================================"
    echo ""
    echo "访问地址："
    echo "  公共求职页面:  http://localhost:5000/"
    echo "  管理后台:      http://localhost:5001/"
    echo ""
    echo "云服务器访问："
    echo "  公共求职页面:  http://your-server-ip:5000/"
    echo "  管理后台:      http://your-server-ip:5001/"
    echo ""
    echo "进程 ID："
    echo "  公共服务: $PUBLIC_PID"
    echo "  管理服务: $ADMIN_PID"
    echo ""
    echo "日志文件："
    echo "  公共服务: $LOG_FILE_PUBLIC"
    echo "  管理服务: $LOG_FILE_ADMIN"
    echo ""
    echo "管理命令："
    echo "  查看状态: ./start_all.sh status"
    echo "  查看日志: tail -f $LOG_FILE_PUBLIC"
    echo "  查看日志: tail -f $LOG_FILE_ADMIN"
    echo "  停止服务: ./start_all.sh stop"
    echo "======================================"
    echo ""
}

# 前台启动（显示日志）
start_foreground() {
    echo "======================================"
    echo "德元升中医馆 - 招聘管理系统"
    echo "======================================"
    echo ""
    echo "正在前台启动服务（显示日志）..."
    echo ""

    cd "$BACKEND_DIR"

    # 启动公共服务
    echo "[1/2] 启动公共页面服务 (端口 5000)..."
    python app.py &
    PUBLIC_PID=$!
    echo $! > "$PID_FILE_PUBLIC"

    sleep 2

    # 启动管理服务
    echo "[2/2] 启动管理后台服务 (端口 5001)..."
    python admin_app.py &
    ADMIN_PID=$!
    echo $! > "$PID_FILE_ADMIN"

    echo ""
    echo "======================================"
    echo "服务启动完成！"
    echo "======================================"
    echo ""
    echo "访问地址："
    echo "  公共求职页面:  http://localhost:5000/"
    echo "  管理后台:      http://localhost:5001/"
    echo ""
    echo "进程 ID："
    echo "  公共服务: $PUBLIC_PID"
    echo "  管理服务: $ADMIN_PID"
    echo ""
    echo "按 Ctrl+C 停止所有服务"
    echo "======================================"
    echo ""

    # 捕获 Ctrl+C
    trap "echo ''; echo '正在停止所有服务...'; kill $PUBLIC_PID $ADMIN_PID 2>/dev/null; rm -f $PID_FILE_PUBLIC $PID_FILE_ADMIN; echo '服务已停止'; exit 0" SIGINT SIGTERM

    wait
}

# 重启服务
restart_services() {
    echo "正在重启服务..."
    stop_services
    sleep 2
    start_background
}

# 主逻辑
case "${1:-}" in
    -f|--foreground)
        start_foreground
        ;;
    stop)
        stop_services
        ;;
    status)
        show_status
        ;;
    restart)
        restart_services
        ;;
    -h|--help)
        echo "用法: $0 [选项]"
        echo ""
        echo "选项:"
        echo "  (无参数)        后台运行服务（默认）"
        echo "  -f, --foreground 前台运行并显示日志"
        echo "  stop            停止所有服务"
        echo "  status          查看服务状态"
        echo "  restart         重启所有服务"
        echo "  -h, --help      显示此帮助信息"
        echo ""
        echo "示例:"
        echo "  $0              # 后台运行"
        echo "  $0 -f           # 前台运行查看日志"
        echo "  $0 status       # 查看状态"
        echo "  $0 stop         # 停止服务"
        ;;
    *)
        start_background
        ;;
esac
