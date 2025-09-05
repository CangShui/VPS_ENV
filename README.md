<h4><code>bash <(curl -s https://raw.githubusercontent.com/CangShui/VPS_ENV/main/vps.sh)
</code></h4>



<h3>确认 sshd_config 生效</h3>
grep -E "Port|PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config

<h3>查看当前拥塞控制算法</h3>
sysctl net.ipv4.tcp_congestion_control

<h3>查看是否加载了 bbr 模块</h3>
lsmod | grep bbr

<h3>检查常用工具是否可用
for cmd in curl wget zip unzip iperf3 dig screen; do
  command -v $cmd >/dev/null && echo "$cmd 已安装" || echo "$cmd 缺失"
done

<h3>检查网络工具</h3>
<pre>dig debian.org</pre>
<pre>iperf3 -v</pre>


<h3>查看 docker 是否运行</h3>
systemctl status docker --no-pager

<h3>验证版本</h3>
docker --version

<h3>测试运行</h3>
docker run --rm hello-world

<h3>查看默认 python3 版本</h3>
python3 -V

<h3>查看 python 命令是否存在</h3>
python -V

<h3>查看 pip3 和 pip 是否指向 3.11</h3>
pip3 -V
pip -V

# 确认 python3.11 实际路径
ls -l /usr/bin/python3 /usr/bin/python /usr/bin/pip3 /usr/bin/pip
