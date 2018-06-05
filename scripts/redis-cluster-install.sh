#!/bin/bash
#此脚本将redis_cluser的6个节点部署在同一台服务器，适合在开发测试环境下部署

pass=`head -n10 /dev/urandom | tr -cd "a-zA-Z" | fold -w 15 | head -1`
ip=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | awk -F ":" '{print$2}'`

redis_config() {
	mkdir -pv /data/redis_cluster/{7000..7005}
	if [ -f /tmp/redis.conf ];then
		for i in `seq 7000 7005`;do
			cp /tmp/redis.conf /data/redis_cluster/$i/
		done
		for j in `find /data/redis_cluster -name redis.conf`;do
			port=`ls $j | awk -F "/" '{print$4}'`
			sed -i "s/^bind.*/bind $ip/g" $j
			sed -i "s/7000/$port/g" $j
			sed -i "s/^masterauth.*/masterauth $pass/g" $j
			sed -i "s/^requirepass.*/requirepass $pass/g" $j
			echo "$j配置文件修改完成"
			redis-server $j
			echo "redis_cluster中$port已启动"
		done
	else	
		echo "/tmp/目录下未上传redis_cluster配置模版文件,请上传"
	fi


}

redis_cluser() {
	echo "节点握手"
	for g in `seq 7001 7005`;do
		redis-cli -h $ip -p 7000 -a $pass cluster meet $ip $g
	done
	redis-cli -h $ip -p 7000 -a $pass  cluster nodes
	echo "分配槽,查看槽"
	redis-cli -h $ip -p 7000 -a $pass cluster addslots {0..5461}
	redis-cli -h $ip -p 7001 -a $pass cluster addslots {5462..10922}
	redis-cli -h $ip -p 7002 -a $pass cluster addslots {10923..16383}
	sleep 5
	redis-cli -h $ip -p 7000 -a $pass cluster info

	echo "7003,7004,7005从节点cluster replicate 7000,7001,7002"
	redis-cli -h $ip -p 7003 -a $pass cluster replicate `redis-cli -h $ip -p 7000 -a $pass  cluster nodes | grep 7000 | awk '{print $1}'`
	redis-cli -h $ip -p 7004 -a $pass cluster replicate `redis-cli -h $ip -p 7000 -a $pass  cluster nodes | grep 7001 | awk '{print $1}'`
	redis-cli -h $ip -p 7005 -a $pass cluster replicate `redis-cli -h $ip -p 7000 -a $pass  cluster nodes | grep 7002 | awk '{print $1}'`
	sleep 5
	redis-cli -h $ip -p 7000 -a $pass  cluster nodes	
}

if [ -f /tmp/redis-3.2.11.tar.gz ];then
	mkdir /data  &&  tar -xf /tmp/redis-3.2.11.tar.gz -C /data
	gcc_num=`rpm -qa | grep gcc | wc -l`
	if [ $gcc_num >= 2 ];then
		cd /data/redis-3.2.11 && make && make install
		echo "redis编译安装完成"
		echo "修改redis_cluster需要的配置文件并启动redis_cluster"
		redis_config
		redis_cluser
		echo "redis 登陆密码 $pass"
	else	
		echo "redis编译安装的环境gcc未安装"
		yum -y install gcc 
		cd /data/redis-3.2.11 && make && make install
		echo "redis编译安装完成"
		redis_config
		redis_cluser		
		echo "redis 登陆密码 $pass"
	fi
else
	echo "/tmp目录下未上传redis-3.2.11.tar.gz文件,请上传后再执行$0"
fi
