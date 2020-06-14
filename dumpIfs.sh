#!/bin/bash

PRGNAME=$0

DUMPIFS=$PWD/dumpifs

prnUsageAndQuit()
{
	echo "Usage: $PRGNAME <ifs image> <destination directory>"
	exit
}

if [ "x$1" = "x" ];then
	prnUsageAndQuit
fi

if [ "x$2" = "x" ];then
	prnUsageAndQuit
fi

dirs=$($DUMPIFS $1 | grep -v ^[a-zA-Z]|grep -v '\-\-\-\-'|awk '{print($3)}'|sort -u |xargs -n 1 dirname |sort -u)
for d in $dirs;do
theDir=$2/$d
echo mkdir -p $theDir
mkdir -p $theDir
done

echo "Enter dir $2"
cd $2

for x in $($DUMPIFS ../$1 | grep -v ^[a-zA-Z]| awk '{print($3)}'|sort -u |xargs -n 1 basename)
do
$DUMPIFS -x ../$1 $x
done
cd ..

