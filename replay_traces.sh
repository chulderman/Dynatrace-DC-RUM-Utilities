#!/bin/bash
# description: Script plays all captures of .pcap or .cap
#    in a directory (or directories) specified autoscaling
#    per capture Mbps based on total count.
# author: chase hulderman <chase@hulderman.com>
# 

INTERFACE=eth1
MAX_MBPS=15

OLDIFS=$IFS
IFS=$'\n'
for directory in "$@"
do
  echo "Finding Captures in: $directory"
  holdArray=($(find $directory -type f -name "*.cap" -or -name "*.pcap"))
  captureArray=("${captureArray[@]}" "${holdArray[@]}")
done
IFS=$OLDIFS

captureCount=${#captureArray[@]}
if (($captureCount > $MAX_MBPS)); then
  echo "You have specified too many captures. Maximum is $MAX_MBPS"
  exit 0
fi 
rate=$((MAX_MBPS/captureCount))
echo $captureArray
for ((i=0; i<${captureCount}; i++));
do
  capture=${captureArray[$i]}
  echo "Replaying: $capture"
  nohup /usr/local/bin/tcpreplay --intf1=$INTERFACE --loop=0 --mbps=$rate $capture 2>&1 >> /var/log/tcpreplay_dcrum.log &
done
echo "Capture Total#: $captureCount"
echo "Mbps per: $rate"
