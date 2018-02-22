#!/bin/bash
#
# This is the timer to keep track of the game
# 
# The time will run for the first 45, and the 90 setting a time of 45+ and 90+ for extra time
# it is possible to adjust the clock from the command line with + and - commands with the number of seconds
#
. `dirname $0`/00_utilities.sh
# This is only for unit test
trace e
testmode=""
[[ -e "$timefile" ]] || { writetime $1 $2 ; testmode=true ; } # this should only be executed for test, starting with 1 min, first 1/2
dsleep=60
extratime=0
sleeptime=$dsleep
while true
do
	trace i "Sleeping $sleeptime"
	sleep $sleeptime
	lasttime=`gettime`
	halftime=`gethalf`
	adjust=`readadjust`
	if [[ ! -z "$adjust" ]] ; then # We have to adjust the time a little here
		if [[ `echo $adjust | cut -c1` = "+" ]] ; then
			# If need to move ahead, we can jump by the number of minute, and the sleep the remainder to get back in synch
			adjustSeconds=`echo $adjust | cut -c2-`
			let lasttime+=adjustseconds/60
			let sleeptime=adjustseconds%60
		else
			sleep `echo $adjust | cut -c2-` # If we are ahead, then we will just sleep back waiting to catch up
		fi
	else
		sleeptime=$dsleep # change back to the default seelp time
	fi
	# TODO This need to know if it is first or second half because the second half check always fails the greater than 45
	[[ `echo $lasttime|tr -d '+'` -eq 45 && `gethalf` = "1" ]] && { lasttime=45+ ; writetime $lasttime $halftime; } # end the first half
	[[ `echo $lasttime|tr -d '+'` -eq 90 && `gethalf` = "2" ]] && { lasttime=90+ ; writetime $lasttime $halftime; } # end the second half
	[[ "`echo $lasttime | cut -c3`" != "+" ]] && let lasttime+=1 || let extratime+=1 # increment the clock
	writetime $lasttime $halftime
	# Call to make the updates for the minute update, as well as the publish of the data
	[[ -z "$testmode" ]] && $bpath/99_minuteupdate.sh &
	trace i "Minute : $lasttime"
	[[ $extratime -gt 10 ]] && break
done
trace x
# We are done updating the clock

