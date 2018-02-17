#!/bin/bash
#
# This is the timer to keep track of the game
# 
# The time will run for the first 45, and the 90 setting a time of 45+ and 90+ for extra time
# it is possible to adjust the clock from the command line with + and - commands with the number of seconds
#
. `dirname $0`/99_utilities.sh
# This is only for unit test
#set -x
trace e
[[ -e "$timefile" ]] || writetime 1
dsleep=60
sleeptime=$dsleep
while true
do
	trace i "Sleeping $sleeptime"
	sleep $sleeptime
	lasttime=`gettime`
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
	let lasttime+=1 # set the next minute
	# TODO This need to know if it is first or second half because the second half check always fails the greater than 45
	[[ $lasttime -eq 46 ]] && { writetime "45+" ; break ; } # end the first half
	[[ $lasttime -eq 91 ]] && { writetime "90+" ; break ; } # end the second half
	writetime $lasttime
	# TODO this should be moved out, since if there is a lock, it will mess up clock
	99_minuteupdate.sh # This will update the number of minutes which a player has player
	echo Minute: $lasttime
done
trace x
# We are done updating the clock

