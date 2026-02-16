#!/bin/bash

echo "========================================"
echo "数据备份脚本 - 准备迁移"
echo "========================================"
echo

# 获取当前日期
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="dys_backup_${DATE}"
BACKUP_FILE="${BACKUP_NAME}.tar.gz"

# 确定项目目录
if [ -d "/home/ubuntu/project/dys" ]; then
    PROJECT_DIR="/home/ubuntu/project/dys"
elif [ -d "/home/project/dys" ]; then
    PROJECT_DIR="/home/project/dys"
else
    echo "错误: 找不到项目目录"
    exit 1
fi

cd "$PROJECT_DIR"

echo "项目目录: $PROJECT_DIR"
echo "备份文件: $BACKUP_FILE"
echo

# 创建临时备份目录
mkdir -p /tmp/$BACKUP_NAME

# 1. 备份数据库
echo "[1/5] 备份数据库..."
if [ -d "backend/instance" ]; then
    mkdir -p /tmp/$BACKUP_NAME/backend/instance
    cp -r backend/instance/* /tmp/$BACKUP_NAME/backend/instance/
    echo "✓ 数据库备份完成"
else
    echo "⚠ 未找到数据库目录"
fi

# 2. 备份上传文件
echo "[2/5] 备份上传文件..."
if [ -d "uploads" ]; then
    mkdir -p /tmp/$BACKUP_NAME/uploads
    cp -r uploads/* /tmp/$BACKUP_NAME/uploads/
    FILE_COUNT=$(find uploads -type f | wc -l)
    echo "✓ 上传文件备份完成 ($FILE_COUNT 个文件)"
else
    echo "⚠ 未找到上传文件目录"
fi

# 3. 备份配置文件
echo "[3/5] 备份配置文件..."
FILES_TO_BACKUP=(
    "backend/app.py"
    "backend/admin_app.py"
    "pyproject.toml"
    "README.md"
)

for file in "${FILES_TO_BACKUP[@]}"; do
    if [ -f "$file" ]; then
        mkdir -p /tmp/$BACKUP_NAME/$(dirname $file)
        cp "$file" /tmp/$BACKUP_NAME/$file
    fi
done
echo "✓ 配置文件备份完成"

# 4. 生成备份信息文件
echo "[4/5] 生成备份信息..."
cat > /tmp/$BACKUP_NAME/BACKUP_INFO.txt <<EOF
备份信息
========================================
备份时间: $(date)
原服务器IP: $(curl -s ifconfig.me)
系统信息: $(uname -a)
项目目录: $PROJECT_DIR

数据统计:
========================================
EOF

# 统计数据库记录数
if [ -f "backend/instance/recruitment.db" ]; then
    cd backend
    python3 - <<PYTHON >> /tmp/$BACKUP_NAME/BACKUP_INFO.txt
from models.models import db, Job, Application, User
from app import app

with app.app_context():
    print(f"职位数量: {Job.query.count()}")
    print(f"简历数量: {Application.query.count()}")
    print(f"用户数量: {User.query.count()}")
PYTHON
    cd ..
fi

echo "数据库大小: $(du -sh backend/instance 2>/dev/null | cut -f1)" >> /tmp/$BACKUP_NAME/BACKUP_INFO.txt
echo "上传文件大小: $(du -sh uploads 2>/dev/null | cut -f1)" >> /tmp/$BACKUP_NAME/BACKUP_INFO.txt

echo "✓ 备份信息生成完成"

# 5. 打包压缩
echo "[5/5] 压缩备份文件..."
cd /tmp
tar -czf $BACKUP_FILE $BACKUP_NAME

# 计算文件大小和MD5
BACKUP_SIZE=$(du -sh $BACKUP_FILE | cut -f1)
BACKUP_MD5=$(md5sum $BACKUP_FILE | cut -d' ' -f1)

# 移动到项目目录
mv $BACKUP_FILE "$PROJECT_DIR/"

# 清理临时文件
rm -rf /tmp/$BACKUP_NAME

echo
echo "========================================"
echo "备份完成！"
echo "========================================"
echo
echo "备份文件: $PROJECT_DIR/$BACKUP_FILE"
echo "文件大小: $BACKUP_SIZE"
echo "MD5校验: $BACKUP_MD5"
echo
echo "查看备份信息:"
echo "tar -tzf $BACKUP_FILE | head -20"
echo
echo "========================================"
echo "传输到新服务器的方法："
echo "========================================"
echo
echo "方法1: 使用SCP传输"
echo "scp $BACKUP_FILE root@111.228.59.77:/home/project/dys/"
echo
echo "方法2: 使用rsync传输（推荐，可断点续传）"
echo "rsync -avz --progress $BACKUP_FILE root@111.228.59.77:/home/project/dys/"
echo
echo "方法3: 下载到本地再上传"
echo "1. 下载: scp current_server:$PROJECT_DIR/$BACKUP_FILE ."
echo "2. 上传: scp $BACKUP_FILE root@111.228.59.77:/home/project/dys/"
echo
echo "========================================"
echo "在新服务器上解压："
echo "========================================"
echo
echo "cd /home/project/dys"
echo "tar -xzf $BACKUP_FILE"
echo "mv ${BACKUP_NAME}/backend/instance ./backend/"
echo "mv ${BACKUP_NAME}/uploads ./"
echo "rm -rf $BACKUP_NAME"
echo
echo "验证MD5（确保传输完整）："
echo "md5sum $BACKUP_FILE"
echo "对比结果: $BACKUP_MD5"
echo
echo "========================================"
