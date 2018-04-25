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
. `dirname $0`/00_command_parse.sh

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

while test $# -gt 0
	command_parse $1
	shift
done
