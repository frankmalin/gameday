#!/bin/bash
#
# this will be called every minute to produce some form of an update
#
#set -x
. `dirname $0`/00_utilities.sh

. $currentgame

function updateEventLog()
{

	local eventlog=$log/EVENT.log
	local goltneve=$log/gol.TNEVE # reverse the order of line

	local c='<DIV ALIGN="CENTER"> @@MINUTE@@ </DIV>'
	local v='<DIV ALIGN="RIGHT">@@v_event@@</DIV>'
	local h='<DIV ALIGN="LEFT">@@h_event@@</DIV>'

# Process the events
	egrep -n "." $eventlog | sort -k1nr -t':' | cut -f2- -d':' > $goltneve

	local logtime=0
	echo "<!-- Event Log -->" > $html/event.html
	cat $goltneve | while read event
	do
		what=`echo $event | cut -f1 -d:`
		logtime=`echo $event | cut -f2 -d'@'`
		whodid=`echo $event | cut -f2- -d: | cut -f1 -d'@'`
		# Cut the minute to see if it has been updated
		[[ "$what" = "Time" ]] && { echo $c | sed "s/@@MINUTE@@/$whodid/g" >> $html/event.html ; continue ; }
		[[ "$lastlog" != "$logtime" ]] && { echo $c | sed "s/@@MINUTE@@/$logtime/g" >> $html/event.html ; lastlog=$logtime ; }
		[[ `echo $whodid | egrep $hometeamname` ]] && { echo $h | sed "s/@@h_event@@/$what: $whodid/g" >> $html/event.html ; continue ; }
       	 	[[ `echo $whodid | egrep $awayteamname` ]] && { echo $v | sed "s/@@v_event@@/$what: $whodid/g" >> $html/event.html ; continue ; }
		echo $c | sed "s/@@MINUTE@@/?? $whodid ??/g" >> $html/event.html 
	done

	sed -i -e "/@@events@@/r $html/event.html" $html/index.html
        sed -i "/@@events@@/d" $html/index.html
}

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
updateEventLog

# push the data to the static web server
 pushTheData

