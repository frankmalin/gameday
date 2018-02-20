#!/bin/bash
#
# this will be called every minute to produce some form of an update
#
#set -x
. `dirname $0`/00_utilities.sh

. $currentgame

function updateTeamScoreBoard() 
{
	trace e
	# Update the team portion of the index
	local teamP=$1
	local scoreboard=""
	local line=""
	local name=""
	local value=""
	[[ $teamP = "h" ]] && scoreboard=$homescoreboard || scoreboard=$awayscoreboard

	sed -i "s/@@MINUTE@@/`gettime`/g" $html/index.html

	cat $scoreboard | while read line
	do
		name=`echo $line | cut -f1 -d':'`
		value=`echo $line | cut -f2- -d':'`
		sed -i "s#@@${teamP}_${name}@@#$value#g" $html/index.html
	done
	trace x
}
function updateScoreBoard()
{
	trace e
	cp $html/index.template $html/index.html
	updateTeamScoreBoard h
	updateTeamScoreBoard a
	trace x
}

function updatePlayersHtml()
{
	trace e
        # This will update the players list
        updatePlayer S h
        updatePlayer S a
        updatePlayer O h
        updatePlayer O a
        updatePlayer R h
        updatePlayer R a
	trace x
}

function pushTheData()
{
	# Prereq aws cli installed on machine	
	# connection information configured for aws
	aws s3 cp $html/index.html s3://mfcgameday/currentgame/ --acl public-read
}

# Make the call to update the minutes played.
updateMinutesPlayed

# Update the scoreboard
updateScoreBoard
updatePlayersHtml

# push the data to the static web server
 pushTheData

