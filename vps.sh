#!/bin/bash
set -e

echo "== 开始 VPS 初始化 =="

# --------------------------
# 0. 先询问 Docker / Python 是否安装
# --------------------------
echo "== 是否安装 Docker 环境？ =="
echo "   1) 安装"
echo "   2) 跳过"
echo -n "请输入选择 [默认 1，10 秒后自动安装]: "
read -t 10 choice_docker || choice_docker=1
[ -z "$choice_docker" ] && choice_docker=1

echo "== 是否编译安装 Python3.11 + pip3？ =="
echo "   1) 安装"
echo "   2) 跳过"
echo -n "请输入选择 [默认 1，10 秒后自动安装]: "
read -t 10 choice_py || choice_py=1
[ -z "$choice_py" ] && choice_py=1

# --------------------------
# 1. 配置 SSH
# --------------------------
echo "== 配置 SSH（允许密码登录、root 登录、端口 44443） =="

cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak.$(date +%Y%m%d-%H%M%S)

sed -i 's/^#*PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
sed -i 's/^#*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*Port .*/Port 44443/' /etc/ssh/sshd_config

systemctl restart sshd || systemctl restart ssh

echo "SSH 已重启，端口改为 44443"

# --------------------------
# 2. 启用 BBR
# --------------------------
echo "== 开启 TCP BBR =="

cat <<EOF >/etc/sysctl.d/99-bbr.conf
# 启用 BBR 拥塞控制
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr

# 增大缓冲区，提升跨境链路吞吐
net.core.rmem_max = 33554432
net.core.wmem_max = 33554432
net.ipv4.tcp_rmem = 4096 87380 33554432
net.ipv4.tcp_wmem = 4096 16384 33554432

# 开启路由转发（透明代理需要）
net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1
EOF

sysctl --system >/dev/null
if sysctl net.ipv4.tcp_congestion_control | grep -q bbr; then
    echo "BBR 启用成功 ✅"
else
    echo "BBR 启用失败 ❌"
fi

# --------------------------
# 3. 更换 APT 源
# --------------------------
echo "== 配置 APT 源 =="

. /etc/os-release
cp /etc/apt/sources.list /etc/apt/sources.list.bak.$(date +%Y%m%d-%H%M%S)

case "$VERSION_ID" in
  10)
    echo "检测到 Debian 10 (buster)，该版本已停止维护，使用 archive 源"
    cat >/etc/apt/sources.list <<EOF
deb http://archive.debian.org/debian buster main contrib non-free
deb http://archive.debian.org/debian buster-updates main contrib non-free
deb http://archive.debian.org/debian-security buster/updates main contrib non-free
EOF
    echo 'Acquire::Check-Valid-Until "false";' >/etc/apt/apt.conf.d/99ignore-valid-until
    ;;
  11)
    cat >/etc/apt/sources.list <<EOF
deb http://mirrors.xtom.com/debian bullseye main contrib non-free
deb http://mirrors.xtom.com/debian bullseye-updates main contrib non-free
deb http://mirrors.xtom.com/debian-security bullseye-security main contrib non-free
EOF
    ;;
  12)
    cat >/etc/apt/sources.list <<EOF
deb http://mirrors.xtom.com/debian bookworm main contrib non-free non-free-firmware
deb http://mirrors.xtom.com/debian bookworm-updates main contrib non-free non-free-firmware
deb http://mirrors.xtom.com/debian-security bookworm-security main contrib non-free non-free-firmware
EOF
    ;;
esac

apt-get update -y || true

# --------------------------
# 4. 安装常用工具
# --------------------------
echo "== 安装常用工具 =="
apt-get install -y curl wget zip unzip iperf3 dnsutils screen

# --------------------------
# 5. 安装 Docker
# --------------------------
if [ "$choice_docker" = "1" ]; then
    echo "开始安装 Docker..."
    apt-get install -y apt-transport-https ca-certificates gnupg lsb-release
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $VERSION_CODENAME stable" > /etc/apt/sources.list.d/docker.list
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    systemctl enable --now docker
    echo "Docker 安装完成 ✅"
else
    echo "跳过 Docker 安装"
fi

# --------------------------
# 6. 编译安装 Python3.11
# --------------------------
if [ "$choice_py" = "1" ]; then
    echo "开始安装 Python3.11..."
    apt-get install -y build-essential libssl-dev zlib1g-dev \
        libncurses5-dev libncursesw5-dev libreadline-dev libsqlite3-dev \
        libgdbm-dev libdb5.3-dev libbz2-dev libexpat1-dev liblzma-dev tk-dev libffi-dev uuid-dev wget

    cd /usr/src
    wget https://www.python.org/ftp/python/3.11.9/Python-3.11.9.tgz
    tar xvf Python-3.11.9.tgz
    cd Python-3.11.9
    ./configure --enable-optimizations
    make -j$(nproc)
    make altinstall

    echo "Python3.11 安装完成"

    if command -v python3 &>/dev/null; then
        mv /usr/bin/python3 /usr/bin/python3.bak.$(date +%s)
    fi
    ln -sf /usr/local/bin/python3.11 /usr/bin/python3
    ln -sf /usr/local/bin/python3.11 /usr/bin/python

    if command -v pip3 &>/dev/null; then
        mv /usr/bin/pip3 /usr/bin/pip3.bak.$(date +%s) || true
    fi
    ln -sf /usr/local/bin/pip3.11 /usr/bin/pip3
    ln -sf /usr/local/bin/pip3.11 /usr/bin/pip

    echo "pip3 for Python3.11 安装完成 ✅"
else
    echo "跳过 Python3.11 安装"
fi

echo "== 全部完成！=="
