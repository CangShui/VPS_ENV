<h3><code>bash <(curl -s https://raw.githubusercontent.com/CangShui/VPS_ENV/main/vps.sh)
</code></h3>h3>



# 确认 sshd_config 生效
grep -E "Port|PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config

# 查看当前拥塞控制算法
sysctl net.ipv4.tcp_congestion_control

# 查看是否加载了 bbr 模块
lsmod | grep bbr

# 检查常用工具是否可用
for cmd in curl wget zip unzip iperf3 dig screen; do
  command -v $cmd >/dev/null && echo "$cmd 已安装" || echo "$cmd 缺失"
done

# 检查网络工具
dig debian.org
iperf3 -v


# 查看 docker 是否运行
systemctl status docker --no-pager

# 验证版本
docker --version

# 测试运行
docker run --rm hello-world

# 查看默认 python3 版本
python3 -V

# 查看 python 命令是否存在
python -V

# 查看 pip3 和 pip 是否指向 3.11
pip3 -V
pip -V

# 确认 python3.11 实际路径
ls -l /usr/bin/python3 /usr/bin/python /usr/bin/pip3 /usr/bin/pip
