#!/bin/bash
PING() {
	echo "ping -c 5 www.baidu.com"
	sleep 2
	ping -c 5 www.baidu.com
}
SOFT_INSTALL() {
	echo "rpm -ivh https://mirrors.ustc.edu.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm"
	sleep 2
	rpm -ivh https://mirrors.ustc.edu.cn/epel/6/x86_64/epel-release-6-8.noarch.rpm
	if [ $? -eq 0 ];then
		echo "yum -y install vim gcc glibc gcc-c++ vim-enhanced unzip  iptraf wget telnet tree openssl openssl-devel zlib zlib-devel pcre pcre-devel ntpdate"
		sleep 2
		yum -y install vim gcc glibc gcc-c++ vim-enhanced unzip  iptraf wget telnet tree openssl openssl-devel zlib zlib-devel pcre pcre-devel ntpdate
	fi
}
DATESYNC() {
	echo "01 01 * * * root /usr/sbin/ntpdate ntp1.aliyun.com &> /dev/null" >> /etc/crontab
	echo "service crond restart"
	sleep 2
	service crond restart
	echo "ntpdate ntp1.aliyun.com"
	sleep 2
	ntpdate ntp1.aliyun.com
}
SPO() {
	echo "ulimit -SHn 65535"
	sleep 2
	ulimit -SHn 65535
	echo "ulimit -SHn 65535" >> /etc/rc.local
	#禁用control-alt-delete组合键以防止误操作
	sed -i 's@ca::ctrlaltdel:/sbin/shutdown -t3 -r now@#ca::ctrlaltdel:/sbin/shutdown -t3 -r now@' /etc/inittab
	#关闭SElinux
	sed -i 's@SELINUX=enforcing@SELINUX=disabled@' /etc/selinux/config
	setenforce 0
	#关闭防火墙
	echo "service iptables stop"
	sleep 2
	service iptables stop
	#ssh服务配置优化
	sed -i 's@#UseDNS yes@UseDNS no@' /etc/ssh/sshd_config
	sed -i '/GSSAPIAuthentication yes/d' /etc/ssh/sshd_config
	echo "service sshd restart"
	sleep 2
	service sshd restart
	#vim基础语法优化
	echo "syntax on" >> /root/.vimrc
	echo "set nohlsearch" >> /root/.vimrc
}
CHKCONFIG() {
	CHKCONFIG_SERVICE=("NetworkManager" "kudzu" "nfslock" "portmap" "iptables" "autofs" "yum-updatesd" "rpcbind" "ip6tables")
	INDEX=$[${#CHKCONFIG_SERVICE[@]}-1]
	for i in `seq 0 $INDEX`;do
        	chkconfig --list ${CHKCONFIG_SERVICE[$i]} &> /dev/null
        	if [ $? -eq 0 ];then
                	ST=`chkconfig --list  | grep ${CHKCONFIG_SERVICE[$i]} | awk '{print $5}' | awk -F : '{print $2}'`
                	if [ $ST == 'on' ];then
                    	chkconfig ${CHKCONFIG_SERVICE[$i]} off && echo "${CHKCONFIG_SERVICE[$i]} 服务已经关闭开机启动"
                	fi
        	fi
	done
}
PING
if [ $? -eq 0 ];then
	SOFT_INSTALL
	DATESYNC
	SPO
	CHKCONFIG
else
	DATESYNC
	SPO
	CHKCONFIG
fi
