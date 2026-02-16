# 服务器环境一键配置指南

## 🎯 功能介绍

这个脚本可以自动配置新服务器的完整开发环境，包括：

- ✅ **Python 3.11** - 最新Python环境 + pip + uv包管理器
- ✅ **Node.js 20.x LTS** - 包含npm、pnpm、yarn、pm2
- ✅ **Mihomo代理** - Clash Meta核心，支持科学上网
- ✅ **Git + SSH密钥** - 自动生成密钥，配置GitHub访问
- ✅ **项目代码克隆** - 自动克隆指定Git仓库
- ✅ **依赖自动安装** - Python和Node.js项目依赖
- ✅ **防火墙配置** - 自动开放必要端口
- ✅ **环境变量配置** - 代理设置、便捷命令

---

## 🚀 快速开始（3步完成）

### 第一步：连接到新服务器

```bash
# 使用SSH连接到京东云服务器
ssh root@111.228.59.77
# 密码: degKpSS

# 修改密码
passwd
```

### 第二步：下载并运行脚本

```bash
# 方法1: 从GitHub下载（推荐）
wget https://raw.githubusercontent.com/tanstardream/dys/main/setup_server_env.sh
chmod +x setup_server_env.sh
./setup_server_env.sh
```

**或者**

```bash
# 方法2: 如果GitHub访问慢，先配置代理
# 参考MIHOMO_GUIDE.md配置Mihomo后再运行
```

### 第三步：按提示输入信息

脚本会询问以下信息：
1. Git用户名（例如：Your Name）
2. Git邮箱（例如：you@example.com）
3. SSH密钥注释（直接回车使用邮箱）
4. 是否重新安装Node.js（如已安装）
5. Git仓库地址（默认：git@github.com:tanstardream/dys.git）
6. 项目目录（默认：/home/project/dys）

---

## 📋 详细步骤说明

### 步骤1: 系统更新
```bash
[STEP] 1. 更新系统软件包...
✓ apt update && apt upgrade
```

### 步骤2: 安装基础工具
```bash
[STEP] 2. 安装基础工具...
✓ 安装curl、wget、git、vim等
```

### 步骤3: 安装Python环境
```bash
[STEP] 3. 安装Python环境...
✓ Python 3.11
✓ pip、setuptools、wheel
✓ uv包管理器
```

### 步骤4: 安装Node.js环境
```bash
[STEP] 4. 安装Node.js环境...
✓ Node.js 20.x LTS
✓ npm、pnpm、yarn
✓ pm2进程管理器
```

### 步骤5: 安装Mihomo代理
```bash
[STEP] 5. 安装Mihomo代理工具...
✓ 下载最新版Mihomo
✓ 配置systemd服务
✓ 创建配置文件目录
```

### 步骤6: 配置Git
```bash
[STEP] 6. 配置Git环境...
请输入Git用户名: Your Name
请输入Git邮箱: you@example.com
✓ Git全局配置完成
```

### 步骤7: 生成SSH密钥
```bash
[STEP] 7. 配置SSH密钥...
✓ 生成4096位RSA密钥
✓ 添加到ssh-agent
✓ 显示公钥

========== SSH公钥 ==========
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQ...
============================
```

**重要：** 将显示的公钥添加到GitHub
1. 访问 https://github.com/settings/keys
2. 点击 "New SSH key"
3. 粘贴公钥
4. 点击 "Add SSH key"

### 步骤8: 测试GitHub连接
```bash
[STEP] 8. 测试GitHub连接...
✓ 验证SSH密钥是否配置成功
```

### 步骤9: 克隆项目代码
```bash
[STEP] 9. 克隆项目代码...
请输入Git仓库地址: git@github.com:tanstardream/dys.git
请输入项目目录: /home/project/dys
✓ 克隆成功
```

### 步骤10: 安装项目依赖
```bash
[STEP] 10. 安装项目依赖...
✓ 检测Python项目，安装Flask等依赖
✓ 检测Node.js项目，运行pnpm install
```

### 步骤11: 配置环境变量
```bash
[STEP] 11. 配置环境变量...
✓ 添加代理函数到.bashrc
✓ 添加便捷命令别名
```

### 步骤12: 配置防火墙
```bash
[STEP] 12. 配置防火墙...
✓ 开放端口 22(SSH)
✓ 开放端口 5000(应用)
✓ 开放端口 5001(管理)
✓ 开放端口 7890(代理)
```

---

## 🔧 脚本完成后的操作

### 1. 配置Mihomo代理（可选）

如果需要使用代理访问GitHub、Docker Hub等：

```bash
# 方法1: 使用订阅链接
wget -O /etc/mihomo/config.yaml "你的订阅链接"

# 方法2: 手动配置
vim /etc/mihomo/config.yaml
# 参考 mihomo_config_template.yaml 模板

# 测试配置
mihomo -t -d /etc/mihomo

# 启动服务
systemctl start mihomo
systemctl enable mihomo

# 启用代理
proxy

# 测试代理
curl https://www.google.com
```

详细配置参考：[MIHOMO_GUIDE.md](MIHOMO_GUIDE.md)

### 2. 启动项目服务

```bash
cd /home/project/dys

# 如果是4核3.7GB服务器
./start_optimized.sh

# 如果是4核16GB服务器
./start_optimized_16g.sh
```

### 3. 验证安装

```bash
# 查看Python版本
python3 --version

# 查看Node.js版本
node --version

# 查看Git配置
git config --global --list

# 测试GitHub连接
ssh -T git@github.com

# 查看Mihomo状态
systemctl status mihomo
```

---

## 🛠️ 手动配置选项

### 如果脚本某步失败，可以手动执行：

#### 手动安装Python
```bash
add-apt-repository -y ppa:deadsnakes/ppa
apt update
apt install -y python3.11 python3.11-dev python3-pip
```

#### 手动安装Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g pnpm yarn pm2
```

#### 手动配置Git SSH密钥
```bash
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
cat ~/.ssh/id_rsa.pub
```

#### 手动克隆项目
```bash
mkdir -p /home/project
cd /home/project
git clone git@github.com:tanstardream/dys.git
cd dys
```

---

## 🌐 使用代理加速

脚本已配置好代理函数，直接使用：

```bash
# 开启代理（需要先启动Mihomo）
proxy

# 关闭代理
unproxy

# Git使用代理
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# Docker使用代理
mkdir -p /etc/systemd/system/docker.service.d
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
EOF
systemctl daemon-reload
systemctl restart docker
```

---

## 📁 重要文件位置

```
/root/.ssh/id_rsa          # SSH私钥
/root/.ssh/id_rsa.pub      # SSH公钥
/etc/mihomo/config.yaml    # Mihomo配置
/opt/mihomo/mihomo         # Mihomo可执行文件
/home/project/dys/         # 项目目录
/root/.bashrc              # 环境变量配置
```

---

## 🔍 常见问题

### Q1: GitHub克隆失败 "Permission denied"
```bash
# 检查SSH密钥
ssh -T git@github.com

# 如果失败，重新生成并添加密钥
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
cat ~/.ssh/id_rsa.pub
# 复制公钥到 https://github.com/settings/keys
```

### Q2: 无法访问GitHub（网络问题）
```bash
# 配置Mihomo代理
vim /etc/mihomo/config.yaml
systemctl start mihomo

# 开启代理
proxy

# 重试克隆
git clone git@github.com:tanstardream/dys.git
```

### Q3: Python依赖安装失败
```bash
# 使用国内镜像
pip3 install -i https://mirrors.aliyun.com/pypi/simple/ flask

# 或使用清华镜像
pip3 install -i https://pypi.tuna.tsinghua.edu.cn/simple/ flask
```

### Q4: Node.js版本不对
```bash
# 卸载旧版本
apt remove nodejs npm

# 重新安装
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
```

### Q5: Mihomo启动失败
```bash
# 查看错误日志
journalctl -u mihomo -n 50

# 测试配置
mihomo -t -d /etc/mihomo

# 检查端口占用
lsof -i :7890
```

---

## 💡 最佳实践

### 1. 安全建议
```bash
# 修改SSH端口（可选）
vim /etc/ssh/sshd_config
# Port 22 改为 Port 2222
systemctl restart sshd
ufw allow 2222/tcp

# 禁用密码登录（使用密钥）
vim /etc/ssh/sshd_config
# PasswordAuthentication no
systemctl restart sshd
```

### 2. 定期更新
```bash
# 更新系统
apt update && apt upgrade -y

# 更新Python包
pip3 list --outdated
pip3 install --upgrade package-name

# 更新Node.js包
npm outdated -g
npm update -g
```

### 3. 自动备份
```bash
# 创建备份脚本
cat > /root/backup.sh <<'EOF'
#!/bin/bash
tar -czf /root/backup_$(date +%Y%m%d).tar.gz /home/project/dys
find /root/backup_*.tar.gz -mtime +7 -delete
EOF

chmod +x /root/backup.sh

# 添加定时任务
crontab -e
# 0 2 * * * /root/backup.sh
```

---

## 📚 相关文档

- [QUICK_MIGRATION.md](QUICK_MIGRATION.md) - 快速迁移指南
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md) - 详细迁移指南
- [MIHOMO_GUIDE.md](MIHOMO_GUIDE.md) - Mihomo代理配置指南
- [README_PERFORMANCE.md](README_PERFORMANCE.md) - 性能优化指南
- [SERVER_COMPARISON.md](SERVER_COMPARISON.md) - 服务器配置对比

---

## ✅ 验证清单

安装完成后，验证以下项目：

- [ ] Python 3.11 安装成功 `python3 --version`
- [ ] pip 可用 `pip3 --version`
- [ ] Node.js 20.x 安装成功 `node --version`
- [ ] pnpm 可用 `pnpm --version`
- [ ] Git 配置完成 `git config --global --list`
- [ ] SSH密钥生成 `ls ~/.ssh/id_rsa.pub`
- [ ] GitHub连接成功 `ssh -T git@github.com`
- [ ] 项目代码克隆 `ls /home/project/dys`
- [ ] Python依赖安装 `pip3 list | grep flask`
- [ ] Mihomo安装（可选）`mihomo -v`
- [ ] 防火墙配置 `ufw status`
- [ ] 环境变量加载 `source ~/.bashrc`

---

## 🎉 完成

如果所有步骤都成功，你现在拥有一个配置完善的开发服务器！

**下一步：**
1. 启动项目服务 `./start_optimized.sh`
2. 配置域名（可选）
3. 配置Nginx反向代理（可选）
4. 设置自动备份

祝使用愉快！
