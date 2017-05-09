#!/bin/bash

# set -x

getStreamAddress() {
  	local streamAddress;
  	local myArray=($(nmap -n -p 8080 -oG - 192.168.1.* | awk '$5 ~ /open/{print $2}'))
	local retVal=1;
	for elem in "${myArray[@]}"
	do   
		# echo "$elem"
		ffprobe -v error -show_entries stream=codec_name http://${elem}:8080/video
		if [ $? -eq 0 ]
		then
			echo "Success at ip $elem"
			streamAddress=$elem
			retVal=0
			break
		else
			echo "no stream at ip $elem"
		fi 
	done

	echo "$streamAddress"
	return $retVal
}

res1=$(getStreamAddress)
if [ $? -eq 0 ]
then
    date +%s%3N
	echo "stream found!"
	echo "$res1" | tail -n1
	# ipAddress=$("$res1" | tail -1)
	# echo "$ipAddress"
else
	echo "no stream found!"
fi 

