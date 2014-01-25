#!/bin/bash

INTERFACE=$1
MAX_IN=$2
MAX_OUT=$3

if ([ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]); then
    echo Usage: $0 [Interface] [Threshold In KBit/s] [Threshold Out KBit/s]
    echo Example: $0 eth0 8000 8000
    exit 1
fi

RESULT=`ifstat -i $INTERFACE 0.1 1 | grep "\W[0-9+].*"`

IFS=' ' read -a VALUES <<< "${RESULT}"

CHECK_IN=`echo "${VALUES[0]} > $MAX_IN" | bc`
CHECK_OUT=`echo "${VALUES[1]} > $MAX_OUT" | bc`

IN_MBIT=`echo "${VALUES[0]} / 1024" | bc`
OUT_MBIT=`echo "${VALUES[1]} / 1024" | bc`

if [ $CHECK_IN == 1 ] ; then
    echo "CRITICAL - Network In: $IN_MBIT MBit"
    exit 2
fi

if [ $CHECK_OUT == 1 ] ; then
    echo "CRITICAL - Network Out: $OUT_MBIT MBit"
    exit 2
fi

echo "OK - IN ${VALUES[0]} KB/s // OUT ${VALUES[1]} KB/s"
exit 0