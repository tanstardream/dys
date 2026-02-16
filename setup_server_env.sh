#!/bin/bash

#=============================================================================
# 服务器基础环境一键安装脚本
# 功能：安装Python、Node.js、Mihomo代理、Git配置、拉取项目代码
#=============================================================================

set -e  # 遇到错误立即退出

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 检查是否为root用户
check_root() {
    if [ "$EUID" -ne 0 ]; then
        log_error "请使用root用户运行此脚本"
        log_info "使用命令: sudo bash $0"
        exit 1
    fi
}

# 显示欢迎信息
show_banner() {
    clear
    echo "========================================="
    echo "  服务器基础环境一键安装脚本"
    echo "========================================="
    echo "本脚本将安装以下组件："
    echo "  1. Python 3.10+"
    echo "  2. Node.js 20.x LTS"
    echo "  3. Mihomo 代理工具"
    echo "  4. Git 及 SSH 密钥"
    echo "  5. 其他必要工具"
    echo "========================================="
    echo
}

# 更新系统
update_system() {
    log_step "1. 更新系统软件包..."
    apt update -y
    apt upgrade -y
    log_info "系统更新完成"
}

# 安装基础工具
install_basic_tools() {
    log_step "2. 安装基础工具..."
    apt install -y \
        curl \
        wget \
        git \
        vim \
        nano \
        unzip \
        tar \
        build-essential \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release \
        htop \
        net-tools \
        ufw
    log_info "基础工具安装完成"
}

# 安装Python
install_python() {
    log_step "3. 安装Python环境..."

    # 检测系统版本
    OS_VERSION=$(lsb_release -rs 2>/dev/null || echo "unknown")

    # 安装Python和pip（使用系统包管理器）
    log_info "安装Python相关包..."
    apt install -y \
        python3 \
        python3-pip \
        python3-venv \
        python3-dev \
        python3-setuptools \
        python3-wheel

    PYTHON_VERSION=$(python3 --version | awk '{print $2}')
    log_info "Python已安装: $PYTHON_VERSION"

    # 对于Ubuntu 24.04+，处理PEP 668保护机制
    if [[ $(echo "$OS_VERSION >= 24.04" | bc -l 2>/dev/null || echo 0) -eq 1 ]] || [ -f /usr/lib/python*/EXTERNALLY-MANAGED ]; then
        log_warn "检测到Python externally-managed环境保护"
        log_info "使用系统包管理器安装Python包..."

        # 安装常用Python包（通过apt）
        apt install -y \
            python3-setuptools \
            python3-wheel \
            python3-virtualenv \
            pipx 2>/dev/null || true

        # 创建pip配置以允许break-system-packages（仅在必要时）
        mkdir -p /root/.config/pip
        cat > /root/.config/pip/pip.conf <<EOF
[global]
break-system-packages = true
EOF
        log_info "已配置pip允许系统级安装"
    else
        # 旧版本Ubuntu，直接升级pip
        python3 -m pip install --upgrade pip 2>/dev/null || apt install -y python3-pip
    fi

    # 安装uv（现代Python包管理器）
    if ! command -v uv &> /dev/null; then
        log_info "安装uv包管理器..."
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.cargo/bin:$PATH"
        log_info "uv 包管理器安装完成"
    else
        log_info "uv已安装"
    fi

    python3 --version
    pip3 --version 2>/dev/null || log_warn "pip未安装或需要使用 python3 -m pip"
}

# 安装Node.js
install_nodejs() {
    log_step "4. 安装Node.js环境..."

    # 检查是否已安装
    if command -v node &> /dev/null; then
        NODE_VERSION=$(node --version)
        log_info "Node.js已安装: $NODE_VERSION"

        # 询问是否重新安装
        read -p "是否重新安装Node.js 20.x LTS? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            return
        fi
    fi

    # 使用NodeSource安装最新LTS版本
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs

    # 安装pnpm和yarn
    npm install -g pnpm yarn pm2

    log_info "Node.js 安装完成"
    node --version
    npm --version
    pnpm --version
}

# 安装Mihomo代理
install_mihomo() {
    log_step "5. 安装Mihomo代理工具..."

    # 创建Mihomo目录
    MIHOMO_DIR="/opt/mihomo"
    mkdir -p $MIHOMO_DIR
    cd $MIHOMO_DIR

    # 检测系统架构
    ARCH=$(uname -m)
    case $ARCH in
        x86_64)
            MIHOMO_ARCH="linux-amd64"
            ;;
        aarch64)
            MIHOMO_ARCH="linux-arm64"
            ;;
        *)
            log_error "不支持的系统架构: $ARCH"
            return 1
            ;;
    esac

    # 下载最新版本Mihomo
    log_info "下载Mihomo ($MIHOMO_ARCH)..."
    MIHOMO_VERSION=$(curl -s https://api.github.com/repos/MetaCubeX/mihomo/releases/latest | grep tag_name | cut -d '"' -f 4)

    if [ -z "$MIHOMO_VERSION" ]; then
        log_warn "无法获取最新版本，使用备用下载链接"
        MIHOMO_VERSION="v1.18.1"
    fi

    DOWNLOAD_URL="https://github.com/MetaCubeX/mihomo/releases/download/${MIHOMO_VERSION}/mihomo-${MIHOMO_ARCH}-${MIHOMO_VERSION}.gz"

    wget -O mihomo.gz "$DOWNLOAD_URL" || {
        log_error "下载Mihomo失败"
        return 1
    }

    # 解压
    gunzip -f mihomo.gz
    chmod +x mihomo
    ln -sf $MIHOMO_DIR/mihomo /usr/local/bin/mihomo

    log_info "Mihomo安装完成: $MIHOMO_VERSION"

    # 创建配置文件目录
    mkdir -p /etc/mihomo

    # 检查配置文件
    if [ ! -f "/etc/mihomo/config.yaml" ]; then
        log_warn "Mihomo配置文件不存在，请手动创建 /etc/mihomo/config.yaml"
        log_info "参考配置模板: mihomo_config_template.yaml"
    fi

    # 创建systemd服务
    create_mihomo_service
}

# 创建Mihomo systemd服务
create_mihomo_service() {
    log_info "创建Mihomo系统服务..."

    cat > /etc/systemd/system/mihomo.service <<'EOF'
[Unit]
Description=Mihomo Proxy Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/mihomo
ExecStart=/usr/local/bin/mihomo -d /etc/mihomo
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    log_info "Mihomo服务已创建（未启动）"
    log_warn "请先配置 /etc/mihomo/config.yaml 后再启动服务"
    log_info "启动命令: systemctl start mihomo"
    log_info "开机自启: systemctl enable mihomo"
}

# 配置Git
configure_git() {
    log_step "6. 配置Git环境..."

    # 输入Git用户信息
    read -p "请输入Git用户名 (例如: Your Name): " GIT_USERNAME
    read -p "请输入Git邮箱 (例如: you@example.com): " GIT_EMAIL

    # 配置Git全局信息
    git config --global user.name "$GIT_USERNAME"
    git config --global user.email "$GIT_EMAIL"
    git config --global core.editor "vim"
    git config --global init.defaultBranch main

    log_info "Git配置完成"
    git config --global --list
}

# 配置SSH密钥
configure_ssh_key() {
    log_step "7. 配置SSH密钥..."

    SSH_DIR="/root/.ssh"
    SSH_KEY="$SSH_DIR/id_rsa"

    mkdir -p $SSH_DIR
    chmod 700 $SSH_DIR

    # 检查是否已有密钥
    if [ -f "$SSH_KEY" ]; then
        log_info "SSH密钥已存在"
        read -p "是否重新生成SSH密钥? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "使用现有SSH密钥"
            cat "$SSH_KEY.pub"
            return
        fi

        # 备份旧密钥
        mv "$SSH_KEY" "$SSH_KEY.backup.$(date +%Y%m%d_%H%M%S)"
        mv "$SSH_KEY.pub" "$SSH_KEY.pub.backup.$(date +%Y%m%d_%H%M%S)"
    fi

    # 生成新密钥
    read -p "请输入SSH密钥注释 (默认: ${GIT_EMAIL:-root@server}): " SSH_COMMENT
    SSH_COMMENT=${SSH_COMMENT:-${GIT_EMAIL:-root@server}}

    ssh-keygen -t rsa -b 4096 -C "$SSH_COMMENT" -f "$SSH_KEY" -N ""

    # 添加到ssh-agent
    eval "$(ssh-agent -s)"
    ssh-add "$SSH_KEY"

    log_info "SSH密钥生成完成"
    echo
    log_info "========== SSH公钥 =========="
    cat "$SSH_KEY.pub"
    echo
    log_info "============================"
    echo
    log_warn "请将上述公钥添加到GitHub: https://github.com/settings/keys"
    echo
    read -p "按回车键继续..."
}

# 测试GitHub连接
test_github_connection() {
    log_step "8. 测试GitHub连接..."

    log_info "测试SSH连接到GitHub..."
    ssh -T git@github.com 2>&1 | tee /tmp/github_test.log

    if grep -q "successfully authenticated" /tmp/github_test.log; then
        log_info "GitHub SSH连接成功！"
    else
        log_warn "GitHub SSH连接失败，请检查SSH密钥配置"
        log_info "确保已将公钥添加到: https://github.com/settings/keys"
    fi
}

# 克隆项目代码
clone_project() {
    log_step "9. 克隆项目代码..."

    # 项目信息
    DEFAULT_REPO="git@github.com:tanstardream/dys.git"
    DEFAULT_DIR="/home/project/dys"

    read -p "请输入Git仓库地址 (默认: $DEFAULT_REPO): " REPO_URL
    REPO_URL=${REPO_URL:-$DEFAULT_REPO}

    read -p "请输入项目目录 (默认: $DEFAULT_DIR): " PROJECT_DIR
    PROJECT_DIR=${PROJECT_DIR:-$DEFAULT_DIR}

    # 创建父目录
    mkdir -p "$(dirname $PROJECT_DIR)"

    # 检查目录是否存在
    if [ -d "$PROJECT_DIR" ]; then
        log_warn "目录已存在: $PROJECT_DIR"
        read -p "是否删除并重新克隆? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$PROJECT_DIR"
        else
            log_info "跳过克隆，使用现有目录"
            cd "$PROJECT_DIR"
            git pull
            return
        fi
    fi

    # 克隆项目
    log_info "克隆项目: $REPO_URL -> $PROJECT_DIR"
    git clone "$REPO_URL" "$PROJECT_DIR"

    if [ $? -eq 0 ]; then
        log_info "项目克隆成功: $PROJECT_DIR"
        cd "$PROJECT_DIR"

        # 显示项目信息
        log_info "当前分支: $(git branch --show-current)"
        log_info "最新提交: $(git log -1 --oneline)"
    else
        log_error "项目克隆失败，请检查SSH密钥和仓库地址"
    fi
}

# 安装项目依赖
install_project_dependencies() {
    log_step "10. 安装项目依赖..."

    if [ ! -d "$PROJECT_DIR" ]; then
        log_warn "项目目录不存在，跳过依赖安装"
        return
    fi

    cd "$PROJECT_DIR"

    # 检查是否有Python项目
    if [ -f "backend/requirements.txt" ] || [ -f "pyproject.toml" ]; then
        log_info "检测到Python项目，安装依赖..."
        cd backend

        # 检查是否需要 --break-system-packages
        PIP_FLAGS=""
        if [ -f /usr/lib/python*/EXTERNALLY-MANAGED ]; then
            PIP_FLAGS="--break-system-packages"
            log_info "使用 --break-system-packages 标志"
        fi

        # 使用国内镜像安装
        python3 -m pip install $PIP_FLAGS -i https://mirrors.aliyun.com/pypi/simple/ \
            flask>=3.0.0 \
            flask-cors>=4.0.0 \
            flask-sqlalchemy>=3.1.0 \
            pyjwt>=2.8.0 \
            python-docx>=1.1.0 \
            werkzeug>=3.0.0 \
            gunicorn>=25.0.0 \
            'gevent>=24.0.0' \
            'zope.event>=5.0' \
            'greenlet>=3.0.0'

        cd ..
        log_info "Python依赖安装完成"
    fi

    # 检查是否有Node.js项目
    if [ -f "package.json" ]; then
        log_info "检测到Node.js项目，安装依赖..."
        pnpm install
        log_info "Node.js依赖安装完成"
    fi
}

# 配置环境变量
configure_environment() {
    log_step "11. 配置环境变量..."

    # 添加到.bashrc
    cat >> /root/.bashrc <<'EOF'

# ========== 自定义环境变量 ==========
# Proxy设置（如果使用Mihomo）
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890
export no_proxy=localhost,127.0.0.1

# 关闭代理的函数
unproxy() {
    unset http_proxy
    unset https_proxy
    echo "代理已关闭"
}

# 开启代理的函数
proxy() {
    export http_proxy=http://127.0.0.1:7890
    export https_proxy=http://127.0.0.1:7890
    echo "代理已开启"
}

# 别名
alias ll='ls -lah'
alias gs='git status'
alias gp='git pull'
alias gc='git commit'
alias ga='git add'

EOF

    log_info "环境变量配置完成"
}

# 配置防火墙
configure_firewall() {
    log_step "12. 配置防火墙..."

    ufw --force enable
    ufw allow 22/tcp      # SSH
    ufw allow 5000/tcp    # 应用端口
    ufw allow 5001/tcp    # 管理后台
    ufw allow 7890/tcp    # Mihomo HTTP代理
    ufw allow 7891/tcp    # Mihomo SOCKS5代理

    ufw status
    log_info "防火墙配置完成"
}

# 显示安装总结
show_summary() {
    echo
    echo "========================================="
    echo "         安装完成总结"
    echo "========================================="
    echo

    # 检查安装状态
    echo "已安装组件："
    echo "  Python:   $(python3 --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo '未安装')"
    echo "  pip:      $(pip3 --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' | head -1 || echo '未安装')"
    echo "  Node.js:  $(node --version 2>&1 || echo '未安装')"
    echo "  npm:      $(npm --version 2>&1 || echo '未安装')"
    echo "  pnpm:     $(pnpm --version 2>&1 || echo '未安装')"
    echo "  Git:      $(git --version 2>&1 | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+' || echo '未安装')"
    echo "  Mihomo:   $(mihomo -v 2>&1 | head -1 || echo '未安装')"
    echo

    echo "重要信息："
    echo "  项目目录: ${PROJECT_DIR:-未设置}"
    echo "  SSH公钥:  /root/.ssh/id_rsa.pub"
    echo "  Mihomo配置: /etc/mihomo/config.yaml"
    echo

    echo "下一步操作："
    echo "  1. 配置Mihomo代理 (如需使用):"
    echo "     vim /etc/mihomo/config.yaml"
    echo "     systemctl start mihomo"
    echo "     systemctl enable mihomo"
    echo
    echo "  2. 启动应用服务:"
    echo "     cd ${PROJECT_DIR:-/home/project/dys}"
    echo "     ./start_optimized.sh"
    echo
    echo "  3. 查看SSH公钥 (添加到GitHub):"
    echo "     cat /root/.ssh/id_rsa.pub"
    echo
    echo "  4. 测试GitHub连接:"
    echo "     ssh -T git@github.com"
    echo
    echo "  5. 测试代理 (如已配置Mihomo):"
    echo "     curl -x http://127.0.0.1:7890 https://www.google.com"
    echo
    echo "========================================="
}

# 主函数
main() {
    show_banner
    check_root

    # 执行安装步骤
    update_system
    install_basic_tools
    install_python
    install_nodejs
    install_mihomo
    configure_git
    configure_ssh_key
    test_github_connection
    clone_project
    install_project_dependencies
    configure_environment
    configure_firewall

    # 显示总结
    show_summary

    log_info "脚本执行完成！"
    log_warn "请重新登录或执行 'source /root/.bashrc' 以加载环境变量"
}

# 运行主函数
main
