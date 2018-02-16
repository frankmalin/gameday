#!/bin/bash
#
# This is the running stats, of the game and will be done with a running command line
#
# 	N	000	Ayo Adebayo (minutes played) (sub in) (sub out) (goal) (caution) (reason) (red) (reason)
#set -x

# team stats
# shots
# shots on net
# Foul
# corners

# Game stats
# which minute
# minute by minute update
# score

# At this time, there has to be a running clock function which is displayed to the screen.
# the clock should be adjust w/ +s or -s function

####

. `dirname $0`/99_utilities.sh

. "$data/gameday.properties"

function usage()
{
	# This if the set of function to make the updates
	cat $props/game_stats.properties  | xargs -i echo {} | tr '@' '\t'
}

function score()
{
	# A goal has been scored
	local team=$1
	local num=$2
	local atminute=$3

	# update ... scoreboard
	update $team goals

	# update player stats (not sure about own goal)
	updateGoal $team $num $atminute
}

function assist()
{
	local team=$1
	local num=$2
	local atminute=$3

	# Update the roster with the assist time

}


# Here is the input item

action="" # init the input action
echo "GAME DAY>"
while read action
do
	echo "gameday $action"

	# process the single characters	
	echo "[INPUT] : $action"
	single=`echo $action | cut -c1`
	case "$single" in
		+)  # increment the clock
			seconds=`echo $action | cut -c2-`
			[[ `echo $seconds | egrep "^[[:digit:]]{1,3}$"` ]] || { echo "Seconds should be a number between 1 and 999, not $seconds" ; continue ; }
			echo "Increment the clock by $seconds seconds"
			adjusttime $single $seconds
			;;
		-)  # decrement the clock
			seconds=`echo $action | cut -c2-`
                        [[ `echo $seconds | egrep "^[[:digit:]]{1,3}$"` ]] || { echo "Seconds should be a number between 1 and 999, not $seconds" ; continue ; }
                        echo "Increment the clock by $seconds seconds"
                        adjusttime $single $seconds
                        ;;
		g) # There was a goal scored
			team=`echo $action | cut -c2`
			[[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			num=`echo $action | cut -c3-`
			[[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
			echo "Goal scored by team : $team, number $num @ miunute : `gettime`"
			score $team $num `gettime` 
			;;
                a) # There was an assist 
                        team=`echo $action | cut -c2`   
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`   
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        echo "Assist by team : $team, number $num @ miunute : `gettime`"
			assist $team $num `gettime`
			;;
               O) # Own goal, but it will go against the home or away team
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        echo "Assist by team : $team, number $num @ miunute : `gettime`"
                        ;;
		i) # This is a sub in
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        echo "Substitute In : $team, number $num @ miunute : `gettime`"
			updateSubIn $team $num `gettime` 
                        ;;
                o) # This is a sub out 
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        echo "Substitute out : $team, number $num @ miunute : `gettime`"
                        updateSubOut $team $num `gettime`
                       ;;
		f) #  foul
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			update $team fouls
			;;
		c) # Corner kick
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			update $team corners
			;;
		s) # shot near net
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			update $team shots
			;;
		S) # Shot on frame and a save
                        team=`echo $action | cut -c2`
                        [[ `echo team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			update $team saves
			;;
		2) # This is the start of the second half, begin the time
			settime 2
			;;
		1) # This is a start of the first half (this will be primed to start maybe)
			settime 1
			initscoreboards
			;;
		E) # Exit
			break
			;;
		[?H]) # Help
			usage
			;;

		*) 
			echo "Unknown option"
		esac
	echo "GAME DAY>" # Echo the prompt
done

