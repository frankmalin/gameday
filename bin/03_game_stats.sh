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

. `dirname $0`/00_utilities.sh

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
	update $team sog 

	# update player stats (not sure about own goal)
	updateGoal $team $num $atminute
}

function ownscore()
{
        # A goal has been scored
        local team=$1
        local num=$2
        local atminute=$3
	
	# Update the the shots and goals
	update `otherteam $team` goals
	update `otherteam $team` sog 

	# update player stats for own goal
	updateGoal $team $num ${atminute}Own
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
clockstate="stopped"
echo -n "GAME DAY> "
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
			trace i "Increment the clock by $seconds seconds"
			adjusttime $single $seconds
			;;
		-)  # decrement the clock
			seconds=`echo $action | cut -c2-`
                        [[ `echo $seconds | egrep "^[[:digit:]]{1,3}$"` ]] || { echo "Seconds should be a number between 1 and 999, not $seconds" ; continue ; }
                        trace i "Increment the clock by $seconds seconds"
                        adjusttime $single $seconds
                        ;;
		g) # There was a goal scored
			team=`echo $action | cut -c2`
			[[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			num=`echo $action | cut -c3-`
			[[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
			trace v "Goal scored by team : `teamname $team`, number $num, `playername $team $num` @ miunute : `gettime`"
			score $team $num `gettime` 
			;;
                a) # There was an assist 
                        team=`echo $action | cut -c2`   
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`   
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        trace v "Assist by team : `teamname $team`, number $num, `playernname $team $num` @ miunute : `gettime`"
			assist $team $num `gettime`
			;;
               O) # Own goal, but it will go against the home or away team
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        trace v "Own goal scored by team : `teamname $team`, number $num, `playername $team $num` @ miunute : `gettime`"
			ownscore $team $num `gettime`
                        ;;
		i) # This is a sub in
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        trace v "Substitute In : `teamname $team`, number $num, `playername $team $num` @ miunute : `gettime`"
			updateSubIn $team $num `gettime` 
                        ;;
                o) # This is a sub out 
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        trace v "Substitute out : `teamname $team`, number $num, `playername $team $num` @ miunute : `gettime`"
                        updateSubOut $team $num `gettime`
                       ;;
		f) #  foul
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			trace v "Foul by `teamname $team` at `gettime`"
			update $team fouls
			;;
		y) # Yellow card issued
                        team=`echo $action | cut -c2`
                        num=`echo $action | cut -c3- | rev | cut -c2- | rev`
			reason=`echo $action | rev | cut -c1 | rev`

                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        trace v "Yellow `teamname $team` at `gettime`"
			updateYellow $team $num $reason
                        ;;
		r) # Red card issued
                        team=`echo $action | cut -c2`
                        num=`echo $action | cut -c3- | rev | cut -c2- | rev`
                        reason=`echo $action | rev | cut -c1 | rev`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        trace v "Foul by `teamname $team` at `gettime`"
			updateRed $team $num $reason
                        ;;

		c) # Corner kick
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			trace v "Corner kick for `teamname $team` at `gettime`"
			update $team corners
			;;
		s) # shot near net
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			trace v "Shot by `teamname $team` at `gettime`"
			update $team shots
			;;
		S) # Shot on frame and a save
                        team=`echo $action | cut -c2`
                        [[ `echo team | egrep "h|a"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			trace v "Shot by `teamname $team` and a save, at `gettime`"
			update `otherteam $team` saves
			update $team sog 
			;;
		2) # This is the start of the second half, begin the time
			trace v "The second half is underway"
			settime 2  ; clockstate=running
			;;
		#h) # It is half time
		#	trace v "Half time"
		#	settime h
		#	;;
		1) # This is a start of the first half (this will be primed to start maybe)
			trace v "The first half is underway"
			settime 1 ; clockstate=running
			initscoreboards
			;;
		T) # This is a test statement to allow for the input to sleep for more input
			trace v "Test Event sleeping"
			sleep 1m
			;;
		E) # Exit
			trace i "Terminate gameday updates"
			break
			;;
		K) # This is really for using in test, to kill the timer
			trace T "test only event: KILL timer"
			ps -ef | egrep timer.sh | egrep -v grep | tr -s ' ' | cut -f2 -d' '  | xargs -i kill -KILL {}
			;;
		[?H]) # Help
			usage
			;;

		*) 
			trace i "Unknown option: $single"
		esac
        [[ "$clockstate" = "stopped" ]] && { trace e "Clock is not running please start the clock" ; }
	echo -n "GAME DAY> " # Echo the prompt
done

