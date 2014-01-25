#!/bin/bash

INTERVAL=$1
INTERFACE=$2

LIMIT_TX=$3
LIMIT_RX=$4

if ([ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ] || [ -z "$4" ]); then
        echo Usage: $0 [Interval] [Interface] [Limit TX Pkts/s] [Limit RX Pkts/s]
        echo Example: $0 1 eth0 8000 8000
        exit 1
fi

R1=`cat /sys/class/net/$INTERFACE/statistics/rx_packets`
T1=`cat /sys/class/net/$INTERFACE/statistics/tx_packets`

sleep $INTERVAL

R2=`cat /sys/class/net/$INTERFACE/statistics/rx_packets`
T2=`cat /sys/class/net/$INTERFACE/statistics/tx_packets`

TX_PPS=`expr $T2 - $T1`
RX_PPS=`expr $R2 - $R1`

CALC_TX=`echo "$TX_PPS > $LIMIT_TX" | bc`
CALC_RX=`echo "$RX_PPS > $LIMIT_RX" | bc`

if [ $CALC_TX == 1 ] ; then
        echo "CRITICAL - Network Out: $TX_PPS Pkts/s"
        exit 2
fi

if [ $CALC_RX == 1 ] ; then
        echo "CRITICAL - Network In: $RX_PPS Pkts/s"
        exit 2
fi

echo "OK - OUT: $TX_PPS Pkts/s // IN: $RX_PPS Pkts/s"
exit 0