#!/bin/bash
set -e

# Constants
get_time=$(date +%s)sec
datetime=$(echo date_time)
time_offset=${3}
time_offset_min=${3}*60
time_offset_hour=${3}*3600

# Current Version
current_version()
{
    echo "v0.1.2"
}

# Help Command
help_command()
{
    # Display help_command
    echo "Please use the following format:"
    echo
    echo "./bashclk.sh <options> <duration>"
    echo
    echo "options:"
    echo "-v           Show current current_version"
    echo "alarm        Set alarm."
    echo "timer        Set duration of alarm."
    echo "stopwatch    Output the time counter."
    echo "datetime     Show the current date and time."
    echo
}

div_floor () {
    DIVIDEND=${1}
    DIVISOR=${2}
    RESULT=$(( ( ${DIVIDEND} - ( ${DIVIDEND} % ${DIVISOR}) )/${DIVISOR} ))
    echo ${RESULT}
}

time_count(){
    s=${1}
    HOUR=$( div_floor ${s} 60/60 )
    s=$((${s}-(60*60*${HOUR})))
    MIN=$( div_floor ${s} 60 )
    SEC=$((${s}-60*${MIN}))
    while [ $HOUR -ge 0 ]; do
    while [ $MIN -ge 0 ]; do
            while [ $SEC -ge 0 ]; do
                    printf "%02d:%02d:%02d\033[0K\r" $HOUR $MIN $SEC
                    SEC=$((SEC-1))
                    sleep 1
            done
            SEC=59
            MIN=$((MIN-1))
    done
    MIN=59
    HOUR=$((HOUR-1))
    done
}

# Continously show the date and time
date_time()
{
    while :; do printf '%s\r' "$(date +%c)"; sleep 1 ; done
}

# Get the options
while getopts ":h :v" option; do
    case $option in
        h) # Display help_command
            help_command
            exit;;
        v) # Display current_version
            current_version
            exit;;
        \?) # Incorrect option
            echo "Error: Invalid option"
            echo
            echo "Enter the following for help_command"
            echo
            echo "./bashclk.sh -h"
            exit;;
    esac
done

# Stopwatch
if [[ "$1" == 'check' && "$2" == 'stopwatch' ]]; then
    echo "STOPWATCH"
    while true; do
        printf "%s\r" $(TZ=UTC date --date now-$get_time +%H:%M:%S.%N)
        sleep 0.1
    done
fi

# Datetime
if [[ "$1" == 'check' && "$2" == 'datetime' ]]; then
    echo "DATE TIME"
    date_time
fi
