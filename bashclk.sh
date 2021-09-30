#!/bin/bash
set -e

# Constants
get_time=$(date +%s)sec
time_offset_hour=${3}*3600
time_offset_sec=${3}
time_offset_min=${3}*60
today=$(date +%s)
date_today=$(date +%m%d%Y)
time_hour=${3}*3600
time_minute=${5}*60
time_second=${7}
check_bash=$(pgrep -f "bashclk.sh timer")
pid_firstbash=$(pgrep -f "bashclk.sh timer" | head -1)
pid_secondbash=$(pgrep -f "bashclk.sh timer" | head -2 | tail -1)
pid_thirdbash=$(pgrep -f "bashclk.sh timer" | head -3 | tail -1)
pid_fourthbash=$(pgrep -f "bashclk.sh timer" | head -4 | tail -1)
bashline_count=$(pgrep -f "bashclk.sh timer" | wc -l)
num=0
count=$((num + 1))
count_alarm=$(tail -1 ./logs/count.log)

# Current Version
current_version()
{
    echo "v0.1.5"
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
# Mark the function as exported
declare -fx div_floor

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
    echo -e " \033[31;5mTime is Up!!\033[0m";
}
# Mark the function as exported
declare -fx time_count

# Continously show the date and time
date_time()
{
    while :; do printf '%s\r' "$(date +%c)"; sleep 1 ; done
}

# Set alarm
alarm_count(){
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
    echo -e " \033[31;5mWake Up!! Wake Up!!! Wake Up!!!! Wake Up!!!\033[0m";
}
# Mark the function as exported
declare -fx alarm_count

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

# -------------------------STOPWATCH-------------------------------------
# Stopwatch
if [[ "$1" == 'check' && "$2" == 'stopwatch' ]]; then
    echo "STOPWATCH"
    while true; do
        printf "%s\r" $(TZ=UTC date --date now-$get_time +%H:%M:%S.%N)
        sleep 0.1
    done
fi
# -------------------------DATETIME--------------------------------------
# Datetime
if [[ "$1" == 'check' && "$2" == 'datetime' ]]; then
    echo "DATE TIME"
    date_time
fi
# -------------------------TIMER-----------------------------------------
# Set timer
if [[ "$1" == 'timer' && "$2" == "-h" && "$4" == "-m" && "$6" == "-s" ]]; then
    rm -rf ./logs/timer.log     # delete the old contents of the log file
    time_offset_all=$(( $time_hour + $time_minute + $time_second ))
    time_count $time_offset_all | tee ./logs/timer.log | tail -1 &  # put the output in a file and display output once done
fi
# Checking timer
if [[ "$1" == 'check' && "$2" == 'timer' ]];then
    # Limit to 5 timer to set
    if [[ $bashline_count == 5 ]]; then
        kill -9 $pid_firstbash
        kill -9 $pid_secondbash
        kill -9 $pid_thirdbash
        kill -9 $pid_fourthbash
        nl ./logs/timer.log | tail -1
    elif [[ $bashline_count == 4 ]]; then
        kill -9 $pid_firstbash
        kill -9 $pid_secondbash
        kill -9 $pid_thirdbash
        nl ./logs/timer.log | tail -1
    elif [[ $bashline_count == 3 ]]; then
        kill -9 $pid_firstbash
        kill -9 $pid_secondbash
        nl ./logs/timer.log | tail -1
    elif [[ $bashline_count == 2 ]]; then
        kill -9 $pid_firstbash
        nl ./logs/timer.log | tail -1
    elif [[ $bashline_count == 1 ]]; then
        nl ./logs/timer.log | tail -1
    else
        echo "Done!" > /dev/null
    fi
fi
# Monitor timer
if [[ $1 = "monitor" && $2 = "timer" ]]; then
    tail -f ./logs/timer.log
fi
# -------------------------ALARM-------------------------------------------
# Set alarm
if [[ $1 == "alarm" ]]; then
    set_date=$2
    set_time=$3
    set_all="$set_date $set_time"
    set_epoch=$(date -d "$set_all" +"%s")
    timetaken=$((set_epoch-$today))
    get_hours=$((timetaken/3600))
    get_minutes=$(((timetaken%3600)/60))
    get_seconds=$((timetaken%60))
    get_timer=$((timetaken-1))
    printf '%s\r' "$(echo "Alarm will go off after $get_hours hrs $get_minutes mins $get_seconds secs")";
    echo $count > ./logs/count.log
    alarm_count $get_timer | tee ./logs/alarms/alarm$count_alarm.log | tail -1 &
fi
