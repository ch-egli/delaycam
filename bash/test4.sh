#!/bin/bash

delay=10

while [ true ]
do

    readarray myArray < ../delay.txt
    delay=${myArray[0]}
    echo $delay

    sleep 2

done
