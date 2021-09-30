#!/bin/bash

set -e

# Constants
add_quote='"'
sleep_delay=0.25
date_format=("date +"%Y-%m-%d"")
time_format=("date +"%T"")
get_time=$(date +%s)sec

# current_version
current_version()
{
    echo "v0.1.0"
}

# help_command
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

if [[ "$1" == 'stopwatch' ]]; then
    while true; do
        printf "%s\r" $(TZ=UTC date --date now-$get_time +%H:%M:%S.%N)
        sleep 0.1
    done
else
    echo "Done!" >> /dev/null
fi
