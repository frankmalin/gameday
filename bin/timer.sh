#!/bin/bash
#
# This is the timer to keep track of the game
. ./utilities.sh
# This is only for unit test
#set -x
[[ -e "$timefile" ]] || writetime 1
dsleep=60
sleeptime=$dsleep
while true
do
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
	[[ $lasttime -eq 46 ]] && { writetime "45+" ; break ; } # end the first half
	[[ $lasttime -eq 91 ]] && { writetime "90+" ; break ; } # end the second half
	writetime $lasttime
	echo Minute: $lasttime
done
# We are done updating the clock

