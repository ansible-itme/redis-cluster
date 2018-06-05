#!/bin/bash
pass=jkdfKedpe3er
for j in `find /data/redis_cluster -name redis.conf`;do
	echo "masterauth $pass" >> $j
	echo "requirepass $pass" >> $j
	redis-server $j
done

