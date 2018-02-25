#!/bin/bash
#
# this will be called every minute to produce some form of an update
#
set -x
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
	local whichboard=$2
	local scoreboard=""
	local line=""
	local name=""
	local value=""
	[[ $teamP = "h" ]] && scoreboard=$homescoreboard || scoreboard=$awayscoreboard

	sed -i "s/@@MINUTE@@/`gettime`/g" $whichboard

	cat $scoreboard | while read line
	do
		name=`echo $line | cut -f1 -d':'`
		value=`echo $line | cut -f2- -d':'`
		sed -i "s#@@${teamP}_${name}@@#$value#g" $whichboard
	done
	trace x
}
function updateScoreBoard()
{
	trace e
	cp $html/index.template $html/index.html
	updateTeamScoreBoard h $html/index.html
	updateTeamScoreBoard a $html/index.html
	cp $json/scoreboard.template $json/scoreboard.json
	updateTeamScoreBoard h $json/scoreboard.json
	updateTeamScoreBoard a $json/scoreboard.json
	trace x
}

function updatePlayersHtml()
{
	trace e
        # This will update the players list
	echo > $json/h.json # create the json files
	echo > $json/a.json
        updatePlayer S h
        updatePlayer S a
        updatePlayer O h
        updatePlayer O a
        updatePlayer R h
        updatePlayer R a
        updatePlayer N h
        updatePlayer N a
	# TODO need to update the files
	sed -i "`wc -l $json/h.json| cut -f1 -d' '`s/},$/}/" $json/h.json
        sed -i -e "/@@h_roster@@/r $json/h.json" $json/scoreboard.json
        sed -i "/@@h_roster@@/d" $json/scoreboard.json
        sed -i "`wc -l $json/a.json| cut -f1 -d' '`s/},$/}/" $json/a.json
        sed -i -e "/@@a_roster@@/r $json/a.json" $json/scoreboard.json
        sed -i "/@@a_roster@@/d" $json/scoreboard.json
	trace x
}

function pushTheData()
{
	# Prereq aws cli installed on machine	
	# connection information configured for aws
echo TODO	aws s3 cp $html/index.html s3://mfcgameday/currentgame/ --acl public-read
}

# Make the call to update the minutes played.
updateMinutesPlayed

# Update the scoreboard
updateScoreBoard
updatePlayersHtml
updateEventLog

# push the data to the static web server
 pushTheData

