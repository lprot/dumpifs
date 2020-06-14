#!/bin/sh
ucltool=$PWD/uuu
lzotool=$PWD/zzz
compressUse=$ucltool

fixdecifs=$PWD/fixdecifs
fixencifs=$PWD/fixencifs

tempBody=__temp__B
tempBody2=__temp__B2

if [ $# -lt 3 ];then
cat << EOF
Usage: $0 <image startup_size(dec)> <decompressed.ifs> <destination.ifs> [format: ucl|lzo]
Image startup_size (usually 260), can be found by running dumpifs over original ifs file.
EOF
exit
fi

if [ $1 -lt 260 ];then
echo "Invalid offset. Should be at least 260"
exit
fi

offsetH=$1
srcIfs=$2
dstIfs=$3

if [ -e $tempBody ];then
echo "Temporary file $tempBody exists!"
exit
fi

if [ -e $tempBody2 ];then
echo "Temporary file $tempBody2 exists!"
exit
fi

if [ -e $dstIfs ];then
echo "Destination file $dstIfs exists!"
exit
fi


if [ "x$4" = "xucl" ]
then
packuse=1
echo "Packing by using ucl"
elif [ "x$4" = "xlzo" ]
then
packuse=2
echo "Packing by using lzo"
else

cat << EOF
Compress method?
1. ucl
2. lzo
EOF

read packuse

fi

if [ "$packuse" -lt 1 -o "$packuse" -gt 2 ];then
	echo "Invalid option $packuse"
	exit
fi


if [ $packuse -eq 1 ];then
	compressUse=$ucltool
fi

if [ $packuse -eq 2 ];then
	compressUse=$lzotool
fi


echo "Fix checksum of decompressed"
$fixdecifs $srcIfs Y

echo "Select $packuse. Use compress tool $compressUse"

dd if=$srcIfs of=$dstIfs bs=$offsetH count=1
dd if=$srcIfs of=$tempBody bs=$offsetH skip=1
$compressUse $tempBody $tempBody2

echo "Add padding"
echo -n "0000" | xxd -r -p >> $tempBody2

echo "Compress using $compressUse done."
echo "Packing $dstIfs"
dd of=$dstIfs if=$tempBody2 bs=$offsetH seek=1

finalSize=`du -b $dstIfs | awk '{print($1)}'`
if [ 0 != $(($finalSize %4)) ]
then
	padlen=$((4 - ($finalSize %4) + 4))
else
	padlen=4
fi
echo "finalSize: $finalSize, padlen: $padlen"

finalSize=`du -b $dstIfs | awk '{print($1)}'`
dd if=/dev/zero of=$dstIfs bs=1 count=$padlen seek=$finalSize

$fixencifs $dstIfs Y

echo "Done"
rm $tempBody
rm $tempBody2
ls -l $dstIfs
