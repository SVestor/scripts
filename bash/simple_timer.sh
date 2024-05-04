#!/bin/bash

sum_of_seconds=""

while getopts "m:s:" opt; do
        case "$opt" in
                m) sum_of_seconds=$(( $sum_of_seconds + $OPTARG * 60 ));;
                s) sum_of_seconds=$(( $sum_of_seconds + $OPTARG ));;
                \?) echo "Invalid options .... should be like './timer.sh -m [arg1] -s [arg2]'";;
        esac

done

while [[ $sum_of_seconds -gt 0  ]]; do
        #printf "\r%d " "$sum_of_seconds"
        echo -ne "\r$sum_of_seconds "
        (( sum_of_seconds-=1  ))
        sleep 1s
        #clear

done

echo "Time's Up !!!"
