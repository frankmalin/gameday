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
	# update `otherteam $team` sog # Remove since this is really not a shot on goal

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

function command_parse()
{
action="$1" # init the input action
#clockstate="stopped"
#echo -n "GAME DAY> "
#while read action
#do

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
			[[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
			num=`echo $action | cut -c3-`
			[[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
			eventD="`teamname $team`, $num `playername $team $num`"
			trace v $(buildevent GOAL `gettime` "$eventD")
			score $team $num `gettime` 
			;;
                a) # There was an assist 
                        team=`echo $action | cut -c2`   
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`   
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
			eventD="`teamname $team`, $num, `playername $team $num`"
			trace v $(buildevent Assist `gettime` "$eventD")
			assist $team $num `gettime`
			;;
               O) # Own goal, but it will go against the home or visitor team
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "OWN GOAL" `gettime` "$eventD")
			ownscore $team $num `gettime`
                        ;;
		i) # This is a sub in
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Substitution IN" `gettime` "$eventD")
			updateSubIn $team $num `gettime` 
                        ;;
                o) # This is a sub out 
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; continue ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Substitution OUT" `gettime` "$eventD")
                        updateSubOut $team $num `gettime`
                       ;;
		f) #  foul
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent Foul `gettime` "$eventD")
			update $team fouls
			;;
		y) # Yellow card issued
                        team=`echo $action | cut -c2`
			num=`echo $action | grep -Eo '[0-9]{1,2}'`
			reason=`echo $action | rev | cut -c1 | rev`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Yellow Card" `gettime` "$eventD")
			updateYellow $team $num `gettime` $reason
                        ;;
		r) # Red card issued
                        team=`echo $action | cut -c2`
                        num=`echo $action | cut -c3- | rev | cut -c2- | rev`
                        reason=`echo $action | rev | cut -c1 | rev`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Red Card" `gettime` "$eventD")
			updateRed $team $num `gettime` $reason
                        ;;

		c) # Corner kick
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent "Corner Kick" `gettime` "$eventD")
			update $team corners
			;;
		s) # shot near net
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent "Shot wide" `gettime` "$eventD")
			update $team shots
			;;
		S) # Shot on frame and a save
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; continue ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent "Shot On" `gettime` "$eventD")
			eventD="$(teamname `otherteam $team`)"
                        trace v $(buildevent "Save" `gettime` "$eventD")
			update `otherteam $team` saves
			update $team sog 
			;;
		2) # This is the start of the second half, begin the time
			trace v $(buildevent Time `gettime` "Start of second half")
			settime 2
			;;
		h) # It is half time
                        trace v $(buildevent Time `gettime` "Halftime")
			settime h
			;;
		1) # This is a start of the first half (this will be primed to start maybe)
			[[ -d $log ]] && mv $log $log-`date | tr ' ' '_' | tr ':' '-'` # start with a fresh set of logs
			settime 1
			trace v $(buildevent Time `gettime` "First Half is underway")	
			initscoreboards
			;;
		T) # This is a test statement to allow for the input to sleep for more input
			trace i "Test Event sleeping"
			sleep 1m
			;;
		E) # Exit
			settime e
			trace v $(buildevent Time `gettime` "End of game")
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
        [[ "`clockstate`" = "stopped" ]] && { trace E "Clock is not running please start the clock" ; }
}

