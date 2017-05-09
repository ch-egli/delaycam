#!/bin/bash

# set -x



getStreamAddress() {
    local streamAddress
  	local myArray=($(nmap -n -p 8080 -oG - 192.168.1.* | awk '$5 ~ /open/{print $2}'))
	local retVal=1;
	for elem in "${myArray[@]}"
	do   
		# echo "$elem"
		ffprobe -v error http://${elem}:8080/video
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

isStreamAlive() {
    ffprobe -v error http://$1:8080/video
    return $?
}

checkVlc() {
    return 0
}

ipAddress="---"
isStreaming=0

while [ true ]
do
    #date +%s%3N

    if [ $isStreaming -eq 0 ]
    then
        res1=$(getStreamAddress)
        if [ $? -eq 0 ]
        then
            ipAddress="$(echo "$res1" | tail -n1)"
            isStreaming=1
            echo "start streaming from $ipAddress..."
        else
            echo "no stream found!"
        fi
    fi

    sleep 1

    if [ $isStreaming -eq 1 ]
    then
        #ffprobe -v error -show_entries stream=codec_name http://${ipAddress}:8080/video
        isStreamAlive $ipAddress
        if [ $? -eq 0 ]
        then
            # echo "Success at ip $ipAddress"
            checkVlc
        else
            echo "no stream at ip $ipAddress"
            isStreaming=0
            echo "stop streaming from $ipAddress..."
        fi
    fi

    echo "isStreaming: $isStreaming"

done
