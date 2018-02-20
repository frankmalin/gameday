#!/bin/bash
#
# This is to test the clock function to make 
#

function tc()
{
	mkdir -p results
	echo `basename $0` $1 $2 >> results/tc
}

rm ../data/timer.properties 

../bin/99_timer.sh 1 1 # Start first minute, first half

sleep 5m  # sleep for 5 minutes
sleep 10  # get past the 5 minutes

# Check to see if the timer is running as we expect
[[ `egrep "time:6" ../data/timer.properties` ]] && tc check5minute passed || tc check5minute failed
[[ `egrep "half:1" ../data/timer.properties` ]] && tc check1half passed || tc check1half failed

sleep 55m # Sleep past the end of the half

# Check to see if the time is set to 45
[[ `egrep "time:45+" ../data/timer.properties` ]] && tc check545plus passed || tc check45plus failed

# The timer should be stopped after waiting 10 minuted into extra time
[[ `ps -e f | egrep -v grep | egrep "bin.bash .*99_timer.sh"` ]] && tc timerstopped passed || tc timerstopped failed
