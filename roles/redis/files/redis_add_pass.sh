#!/bin/bash
password=jRkklwn5lerw9onkso

for j in `find /data/redis_cluster -name redis.conf`;do
	echo "masterauth $password" >> $j
	echo "requirepass $password" >> $j
	redis-server $j
done

