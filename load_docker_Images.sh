#!/bin/bash

# 批量导入docker镜像

# 脚本目录
ROOTDIR=$(cd $(dirname $0);pwd)
# 进程数量
PROCESS=${1:-10}
# 镜像保存目录
INPUTDIR=${2:-"$ROOTDIR/images"}

if [ ! -d "$INPUTDIR" ];then
    echo "images in $INPUTDIR not found"
    exit 1
fi

trap "exec 3>&-;exec 3<&-;exit 0" 2
[ -e ./$$ ] || mkfifo ./$$
exec 3<> ./$$
rm -rf ./$$
for i in $(seq $PROCESS)
do
	echo >&3
done

for image in $(ls -l $INPUTDIR)
do 
    read -u3
    {
        echo "load image $image"
        docker load -i $image 
        echo >&3
    }&
done
wait
echo 3>&-
echo 3<&-