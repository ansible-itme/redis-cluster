#!/bin/bash

ip=`ifconfig eth0 | grep "inet addr" | awk '{print $2}' | awk -F ":" '{print$2}'`

for j in `find /data/redis_cluster -name redis.conf`;do
       port=`ls $j | awk -F "/" '{print$4}'`
       sed -i "s/^bind.*/bind $ip/g" $j
       sed -i "s/7000/$port/g" $j
       echo "$j配置文件修改完成"
       redis-server $j
       echo "redis_cluster中$port已启动"
done

