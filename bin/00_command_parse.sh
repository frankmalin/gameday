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


function command_parse()
{
action="$1" # init the input action
dummyloop=1
# This is a while do to allow for control, not really looping
while test $dummyloop -gt 0 
do
	dummyloop=0

	echo "gameday $action"

	# process the single characters	
	echo "[INPUT] : $action"
	single=`echo $action | cut -c1`
	case "$single" in
		+)  # increment the clock
			seconds=`echo $action | cut -c2-`
			[[ `echo $seconds | egrep "^[[:digit:]]{1,3}$"` ]] || { echo "Seconds should be a number between 1 and 999, not $seconds" ; break ; }
			trace i "Increment the clock by $seconds seconds"
			adjusttime $single $seconds
			;;
		-)  # decrement the clock
			seconds=`echo $action | cut -c2-`
                        [[ `echo $seconds | egrep "^[[:digit:]]{1,3}$"` ]] || { echo "Seconds should be a number between 1 and 999, not $seconds" ; break ; }
                        trace i "Increment the clock by $seconds seconds"
                        adjusttime $single $seconds
                        ;;
		G) # There was a goal scored
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        # num=`echo $action | cut -c3-`
                        # [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent GOAL `gettime` $eventD)
                        score $team
                        ;;
		d) # The goal was disallowed
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team` previous goal is disallowed"
                        trace v $(buildevent "GOAL DISALLOWED" `gettime` $eventD)
                        disallowed $team 
                        ;;
		g) # There was a goal scored
			team=`echo $action | cut -c2`
			[[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
			num=`echo $action | cut -c3-`
			[[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
			eventD="`teamname $team`, $num `playername $team $num`"
			trace v $(buildevent "SCORED BY" `gettime` "$eventD")
			credit $team $num `gettime` 
			;;
                a) # There was an assist 
                        team=`echo $action | cut -c2`   
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        num=`echo $action | cut -c3-`   
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
			eventD="`teamname $team`, $num, `playername $team $num`"
			trace v $(buildevent Assist `gettime` "$eventD")
			assist $team $num `gettime`
			;;
               O) # Own goal, but it will go against the home or visitor team
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "OWN GOAL" `gettime` "$eventD")
			ownscore $team $num `gettime`
                        ;;
		i) # This is a sub in
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Substitution IN" `gettime` "$eventD")
			updateSubIn $team $num `gettime` 
                        ;;
                o) # This is a sub out 
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        num=`echo $action | cut -c3-`
                        [[ `echo $num | egrep "^[[:digit:]]{1,2}$"` ]] || { echo "The last parm: $num, should be numerical" ; break ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Substitution OUT" `gettime` "$eventD")
                        updateSubOut $team $num `gettime`
                       ;;
		f) #  foul
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent Foul `gettime` "$eventD")
			update $team fouls
			;;
	       P) # Penalty Kick
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent Foul `gettime` "$eventD")
                        update $team pk 
                        ;;
               u) # Offsides (flag is up) 
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent OFFSIDES `gettime` "$eventD")
                        update $team offsides 
                        ;;

		y) # Yellow card issued
                        team=`echo $action | cut -c2`
			num=`echo $action | grep -Eo '[0-9]{1,2}'`
			reason=`echo $action | rev | cut -c1 | rev`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Yellow Card" `gettime` "$eventD")
			updateYellow $team $num `gettime` $reason
                        ;;
		r) # Red card issued
                        team=`echo $action | cut -c2`
                        num=`echo $action | cut -c3- | rev | cut -c2- | rev`
                        reason=`echo $action | rev | cut -c1 | rev`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`, $num, `playername $team $num`"
                        trace v $(buildevent "Red Card" `gettime` "$eventD")
			updateRed $team $num `gettime` $reason
                        ;;

		C) # This is to force the update of the percent (which is not totally integrated into the code)
			updatePercent "h" "`tail $data/h.possession`"
			updatePercent "v" "`tail $data/v.possession`"
			;; 

		c) # Corner kick
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent "Corner Kick" `gettime` "$eventD")
			update $team corners
			;;
		s) # shot near net
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
                        eventD="`teamname $team`"
                        trace v $(buildevent "Shot" `gettime` "$eventD")
			update $team shots
			;;
		S) # Shot on frame and a save
                        team=`echo $action | cut -c2`
                        [[ `echo $team | egrep "h|v"` ]] || { echo "Team should be h or a not: $team" ; break ; }
			eventD="$(teamname $team)"
                        trace v $(buildevent "Save" `gettime` "$eventD")
			update $team saves
			update `otherteam $team` sog 


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
#		k) # This is a goal kick
#			#
#			;;	
		[?H]) # Help
			usage
			;;

		*) 
			trace i "Unknown option: $single"
		esac
        [[ "`clockstate`" = "stopped" ]] && { trace E "Clock is not running please start the clock" ; }
	break; # this is only a single loop, the while do simply controls the error behaviour the input
done
}

