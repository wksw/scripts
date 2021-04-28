#!/bin/bash

# 批量保存docker镜像

# 脚本目录
ROOTDIR=$(cd $(dirname $0);pwd)
# 进程数量
PROCESS=${1:-10}
# 镜像保存目录
OUTPUT=${2:-"$ROOTDIR/images"}

echo "output to $OUTPUT"

# 如果输出目录不存在则创建目录
[ -d "$OUTPUT" ] || mkdir -p $OUTPUT

trap "exec 3>&-;exec 3<&-;exit 0" 2
[ -e ./$$ ] || mkfifo ./$$
exec 3<> ./$$
rm -rf ./$$
for i in $(seq $PROCESS)
do
	echo >&3
done

for image in $(docker images -aq)
do 
    read -u3
    {
        echo "save image $image"
        docker save $image |gzip -c > $OUTPUT/${image}.tar.gz 
        echo >&3
    }&
done
wait
echo 3>&-
echo 3<&-