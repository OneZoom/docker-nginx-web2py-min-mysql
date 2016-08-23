#!/bin/bash
set -e

PWD=`pwd`

echo " --> Starting container"
ID=`docker run -d -v $PWD/test:/test $NAME:$VERSION /sbin/my_init`
sleep 5

echo " --> Checking whether all services are running..."
docker exec -t $ID /bin/bash /test/status.sh
sleep 1

echo " --> Stopping container"
docker stop $ID >/dev/null
docker rm $ID >/dev/null
