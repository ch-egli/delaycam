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

checkVlcIsRunning() {
    if pgrep -x "vlc" > /dev/null
    then
        echo "VLC is already running"
    else
        echo "VLC is stopped, restarting it..."

        # read delay from file
        readarray myArray < ../delay.txt
        delay=${myArray[0]}
        echo $delay

        myCmd="vlc --audio-desync=-$delay http://$1:8080/video &"
        eval $myCmd
    fi
}

killVlcInstances() {
    pkill -15 vlc | pkill -9 vlc
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
            echo "no stream found: kill eventual VLC processes"
            killVlcInstances
        fi
    fi

    sleep 2

    if [ $isStreaming -eq 1 ]
    then
        #ffprobe -v error -show_entries stream=codec_name http://${ipAddress}:8080/video
        isStreamAlive $ipAddress
        if [ $? -eq 0 ]
        then
            # echo "Success at ip $ipAddress"
            checkVlcIsRunning $ipAddress
        else
            echo "no stream at ip $ipAddress"
            isStreaming=0
            echo "stop streaming from $ipAddress..."
            killVlcInstances
        fi
    fi

    echo "isStreaming: $isStreaming"

done
