#!/bin/bash

# set -x

declare streamAddress;

date +%s%3N
myArray=($(nmap -n -p 8080 -oG - 192.168.1.* | awk '$5 ~ /open/{print $2}'))

for elem in "${myArray[@]}"
do   
    # echo "$elem"
	ffprobe -v error -show_entries stream=codec_name http://${elem}:8080/video
	if [ $? -eq 0 ]
	then
  		echo "Success at ip $elem"
		streamAddress=$elem
		break;
	else
  		echo "no stream at ip $elem"
	fi 
done

date +%s%3N

echo "done"
echo "$streamAddress"