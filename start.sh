#!/bin/bash

echo "================================"
echo "招聘网站系统 - 快速启动"
echo "================================"
echo

echo "检查Python环境..."
python3 --version
if [ $? -ne 0 ]; then
    echo "错误: 未找到Python，请先安装Python 3.7+"
    exit 1
fi

echo
echo "检查依赖..."
cd backend

if [ ! -d "venv" ]; then
    echo "创建虚拟环境..."
    python3 -m venv venv
fi

echo "激活虚拟环境..."
source venv/bin/activate

echo "安装依赖包..."
pip install -r requirements.txt

echo
echo "================================"
echo "启动后端服务..."
echo "访问地址: http://localhost:5000"
echo "================================"
echo
echo "前端页面:"
echo "- 外部投递页面: frontend/index.html"
echo "- 管理后台: frontend/admin.html"
echo
echo "默认管理员账号:"
echo "用户名: admin"
echo "密码: admin123"
echo
echo "按 Ctrl+C 停止服务"
echo "================================"
echo

python app.py
