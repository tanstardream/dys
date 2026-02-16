# Mihomo 代理配置指南

## 📖 配置文件说明

Mihomo是Clash Meta的核心，提供强大的代理功能。

### 配置文件位置
- 配置文件: `/etc/mihomo/config.yaml`
- 可执行文件: `/usr/local/bin/mihomo`
- 工作目录: `/opt/mihomo`

---

## 🚀 快速配置

### 方法1: 使用订阅链接（推荐）

如果你有订阅链接，可以直接下载配置：

```bash
# 下载订阅配置
wget -O /etc/mihomo/config.yaml "你的订阅链接"

# 或使用curl
curl -o /etc/mihomo/config.yaml "你的订阅链接"

# 检查配置是否有效
mihomo -t -d /etc/mihomo

# 启动服务
systemctl start mihomo
systemctl enable mihomo
```

### 方法2: 手动配置

```bash
# 复制模板
cp mihomo_config_template.yaml /etc/mihomo/config.yaml

# 编辑配置
vim /etc/mihomo/config.yaml

# 修改以下内容：
# 1. 替换示例节点为你的真实节点
# 2. 配置secret（可选）
# 3. 根据需要调整规则
```

---

## 📝 配置文件结构

### 基础设置
```yaml
mixed-port: 7890        # HTTP和SOCKS5混合端口
allow-lan: true         # 允许局域网连接
mode: rule              # 规则模式
log-level: info         # 日志级别
external-controller: 0.0.0.0:9090  # Web控制面板
```

### 代理节点配置

#### Shadowsocks节点
```yaml
- name: "SS节点"
  type: ss
  server: your-server.com
  port: 443
  cipher: aes-256-gcm
  password: "your-password"
  udp: true
```

#### VMess节点
```yaml
- name: "VMess节点"
  type: vmess
  server: your-server.com
  port: 443
  uuid: your-uuid-here
  alterId: 0
  cipher: auto
  udp: true
  network: ws
  ws-opts:
    path: /path
    headers:
      Host: your-server.com
```

#### Trojan节点
```yaml
- name: "Trojan节点"
  type: trojan
  server: your-server.com
  port: 443
  password: "your-password"
  udp: true
  sni: your-server.com
  skip-cert-verify: false
```

---

## 🎯 常用规则配置

### GitHub加速
```yaml
rules:
  - DOMAIN-SUFFIX,github.com,PROXY
  - DOMAIN-SUFFIX,githubusercontent.com,PROXY
  - DOMAIN-SUFFIX,github.io,PROXY
```

### Docker加速
```yaml
rules:
  - DOMAIN-SUFFIX,docker.com,PROXY
  - DOMAIN-SUFFIX,docker.io,PROXY
  - DOMAIN-SUFFIX,gcr.io,PROXY
```

### NPM加速
```yaml
rules:
  - DOMAIN-SUFFIX,npmjs.org,PROXY
  - DOMAIN-SUFFIX,npmjs.com,PROXY
  - DOMAIN-SUFFIX,yarnpkg.com,PROXY
```

---

## 🔧 服务管理

### 启动/停止/重启
```bash
# 启动服务
systemctl start mihomo

# 停止服务
systemctl stop mihomo

# 重启服务
systemctl restart mihomo

# 查看状态
systemctl status mihomo

# 开机自启
systemctl enable mihomo

# 取消自启
systemctl disable mihomo
```

### 查看日志
```bash
# 实时查看日志
journalctl -u mihomo -f

# 查看最近100行日志
journalctl -u mihomo -n 100

# 查看今天的日志
journalctl -u mihomo --since today
```

### 测试配置
```bash
# 测试配置文件
mihomo -t -d /etc/mihomo

# 手动运行（调试用）
mihomo -d /etc/mihomo
```

---

## 🌐 使用代理

### 临时使用代理

```bash
# HTTP代理
export http_proxy=http://127.0.0.1:7890
export https_proxy=http://127.0.0.1:7890

# SOCKS5代理
export all_proxy=socks5://127.0.0.1:7890

# 测试代理
curl -I https://www.google.com
```

### 永久配置代理

已在 `/root/.bashrc` 中配置，使用以下函数：

```bash
# 开启代理
proxy

# 关闭代理
unproxy

# 测试代理
curl -x http://127.0.0.1:7890 https://www.google.com
```

### Git使用代理

```bash
# 全局配置
git config --global http.proxy http://127.0.0.1:7890
git config --global https.proxy http://127.0.0.1:7890

# 仅GitHub使用代理
git config --global http.https://github.com.proxy http://127.0.0.1:7890

# 取消代理
git config --global --unset http.proxy
git config --global --unset https.proxy
```

### Docker使用代理

```bash
# 创建配置目录
mkdir -p /etc/systemd/system/docker.service.d

# 创建代理配置
cat > /etc/systemd/system/docker.service.d/http-proxy.conf <<EOF
[Service]
Environment="HTTP_PROXY=http://127.0.0.1:7890"
Environment="HTTPS_PROXY=http://127.0.0.1:7890"
Environment="NO_PROXY=localhost,127.0.0.1"
EOF

# 重启Docker
systemctl daemon-reload
systemctl restart docker
```

---

## 🎛️ Web控制面板

访问: http://your-server-ip:9090/ui

推荐使用以下面板：
- [Yacd](http://yacd.haishan.me)
- [Clash Dashboard](https://clash.razord.top)

配置外部控制器：
```yaml
external-controller: 0.0.0.0:9090
secret: "your-secret-here"  # 设置访问密码
```

---

## 📊 性能优化

### DNS配置
```yaml
dns:
  enable: true
  listen: 0.0.0.0:53
  enhanced-mode: fake-ip
  nameserver:
    - 223.5.5.5
    - 119.29.29.29
  fallback:
    - 8.8.8.8
    - 1.1.1.1
```

### 缓存设置
```yaml
profile:
  store-selected: true
  store-fake-ip: true
```

---

## 🔒 安全建议

1. **设置访问密码**
   ```yaml
   secret: "strong-password-here"
   ```

2. **限制外部访问**
   ```yaml
   external-controller: 127.0.0.1:9090  # 仅本地访问
   ```

3. **使用防火墙**
   ```bash
   # 仅允许本地访问控制面板
   ufw deny 9090/tcp
   ```

---

## 🆘 常见问题

### Q1: 启动失败
```bash
# 检查配置文件
mihomo -t -d /etc/mihomo

# 查看详细错误
journalctl -u mihomo -n 50
```

### Q2: 代理不生效
```bash
# 检查服务状态
systemctl status mihomo

# 测试端口
curl -v http://127.0.0.1:7890

# 检查防火墙
ufw status
```

### Q3: 节点连接失败
```bash
# 测试节点连通性
curl -x http://127.0.0.1:7890 https://www.google.com

# 查看日志
journalctl -u mihomo -f
```

### Q4: 更新配置后不生效
```bash
# 重启服务
systemctl restart mihomo

# 或重载配置（如果支持）
curl -X PUT http://127.0.0.1:9090/configs -d '{"path":"/etc/mihomo/config.yaml"}'
```

---

## 📚 参考资源

- [Mihomo官方文档](https://wiki.metacubex.one/)
- [Clash配置文档](https://dreamacro.github.io/clash/)
- [订阅转换](https://sub.xeton.dev/)

---

## 💡 使用示例

### 加速GitHub克隆
```bash
# 启用代理
proxy

# 克隆项目
git clone https://github.com/username/repo.git

# 关闭代理
unproxy
```

### 加速Docker拉取
```bash
# 配置Docker代理后
docker pull nginx:latest
```

### 加速NPM安装
```bash
# 使用代理
export http_proxy=http://127.0.0.1:7890
npm install
```

---

## ⚙️ 自动化配置脚本

如果你有订阅链接，可以创建自动更新脚本：

```bash
#!/bin/bash
# 文件: /root/update_mihomo.sh

SUBSCRIBE_URL="你的订阅链接"

# 下载最新配置
wget -O /etc/mihomo/config.yaml.new "$SUBSCRIBE_URL"

# 验证配置
if mihomo -t -d /etc/mihomo -f config.yaml.new; then
    mv /etc/mihomo/config.yaml.new /etc/mihomo/config.yaml
    systemctl restart mihomo
    echo "配置更新成功"
else
    echo "配置验证失败"
    rm /etc/mihomo/config.yaml.new
fi
```

添加到定时任务：
```bash
chmod +x /root/update_mihomo.sh

# 每天凌晨3点更新
crontab -e
# 添加: 0 3 * * * /root/update_mihomo.sh
```
