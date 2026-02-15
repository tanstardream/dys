#!/bin/bash
# 启动招聘系统的所有服务

echo "======================================"
echo "德元升中医馆 - 招聘管理系统"
echo "======================================"
echo ""
echo "正在启动服务..."
echo ""

# 启动公共页面服务 (5000端口)
echo "[1/2] 启动公共页面服务 (端口 5000)..."
cd backend
python app.py &
PUBLIC_PID=$!
cd ..

# 等待1秒
sleep 1

# 启动管理后台服务 (5001端口)
echo "[2/2] 启动管理后台服务 (端口 5001)..."
cd backend
python admin_app.py &
ADMIN_PID=$!
cd ..

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

# 等待用户按 Ctrl+C
wait
