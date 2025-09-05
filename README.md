<h4><code>bash <(curl -s https://raw.githubusercontent.com/CangShui/VPS_ENV/main/vps.sh)
</code></h4>



<h3>确认 sshd_config 生效</h3>
grep -E "Port|PermitRootLogin|PasswordAuthentication" /etc/ssh/sshd_config</pre>

<h3>查看当前拥塞控制算法</h3>
<pre>sysctl net.ipv4.tcp_congestion_control</pre>

<h3>查看是否加载了 bbr 模块</h3>
<pre>lsmod | grep bbr</pre>

<h3>检查常用工具是否可用</h3>
<pre>for cmd in curl wget zip unzip iperf3 dig screen; do
  command -v $cmd >/dev/null && echo "$cmd 已安装" || echo "$cmd 缺失"
done</pre>

<h3>检查网络工具</h3>
<pre>dig debian.org</pre>
<pre>iperf3 -v</pre>


<h3>查看 docker 是否运行</h3>
<pre>systemctl status docker --no-pager</pre>

<h3>验证版本</h3>
<pre>docker --version</pre>

<h3>测试运行</h3>
<pre>docker run --rm hello-world</pre>

<h3>查看默认 python3 版本</h3>
<pre>python3 -V</pre>

<h3>查看 python 命令是否存在</h3>
<pre>python -V</pre>

<h3>查看 pip3 和 pip 是否指向 3.11</h3>
<pre>pip3 -V</pre>
<pre>pip -V</pre>

# 确认 python3.11 实际路径
<pre>ls -l /usr/bin/python3 /usr/bin/python /usr/bin/pip3 /usr/bin/pip</pre>
