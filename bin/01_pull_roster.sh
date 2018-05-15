#!/bin/bash
#
#
# get the roster
# select the active roster
# select the starter
# Start the game, start the second 1/2
# select subs in and subout
# select Yellow, Red and Goal
#
# Display the game report
#
#set -x


. `dirname $0`/00_utilities.sh

baselink="http://npsl.bonzidev.com/teams"
logolink="http://npsl.bonzidev.com/imagedata"

function findTeamBonziLink() {
	local teamName=$1
	local teamLink=`lynx -dump $baselink | egrep sam.team | egrep -i "$teamName" | tr -s ' ' | cut -f3 -d' ' | tr ' ' '\n'` # try to find only one link
	[[ `echo $teamLink | wc -l` -eq 1 ]] && echo findTeamBonziLink: $teamLink || { echo error, too many or too few links for : $teamName, result: $teamLink ; exit 1 ; }
}

function findTeamLogo() {
	#http://npsl.bonzidev.com/imagedata/logo_Med_City_FC.png
	local lookupName=$1
	local logoName=`lynx -dump $baselink  | egrep -i logo | egrep -i "$lookupName" | tr '[' '\n'  | egrep -i "$lookupName" | cut -f1 -d']'`
	echo findTeamLogo: $logolink/$logoName
}

function buildRoster()
{
	local link=$1 # this is the link for the team
	local teamroster=$2
	rm $teamroster.raw 2>/dev/null || true
	# TODO The web page may be free formatted, which may mean that the schedule is not next ... the code should be such that it loops thru, until the first non blank first character
	#set `lynx -dump $link | xargs -i echo "@{}@" | tr -s ' ' | tr ' ' '_' | egrep -v "@@" | egrep -v "@[a-z]" | egrep -A200 "@Roster@$" | egrep -B100 "@Announcement@$"`
	list=`lynx -dump $link | tr -s ' ' | tr ' ' '_' | egrep -A200 "^Roster$"  | egrep -B200 "^Schedule$" | egrep -v "^$|^#|^_.*jpg.$" | egrep "^_" | sed "s#\[..\]##g" | sed "s#\[.\]##g"`

	if [[ `echo $list | tr ' ' '\n' | rev | cut -f1 -d'_' | rev | sort -u | wc -l` -lt 8 ]] ; then 
		# Remove the last tuplet
		list=`echo $list | xargs -i -d' ' echo {}  | rev | cut -f2- -d'_' | rev` 
	fi
	set `echo $list`
	shift # get past the first two lines
	while test $# -gt 0
	do
		# This is a parse of the output
		[[ `echo $1 | egrep "^_[0-9]"` || `echo $1 | egrep "^.*_.*$"` ]] || { echo end of roster ; break ; } 
		[[ `echo $1 | egrep "^_[0-9]"` ]] && { number=`echo $1 | cut -c2- | cut -f1 -d'_'` ; ncut=3 ; } || { number=000 ; ncut=2 ; }	
		name=`echo $1 | cut -f${ncut}- -d'_'`
		echo -e  "\t$number\t$name" >> $teamroster.raw
		shift
	done
	cat $teamroster.raw | sort -k1n > $teamroster

}

function validateRoster()
{
	trace e
	# At the end, we expect a number, and name separated by tabs, the space in name have been replaced by _
	egrep -v '^\s[0-9]{1,2}\s[[:alpha:]_-]{1,40}$' $1
	[[ $? -eq 0 ]] && { trace E "$1 not all valid, see previous output" ; } || { trace i "input valid" ; }
	trace x
}

home=""
visitor=""
homeroster=""
visitorroster=""

trace e

# Dump out the links team names
teamgrep="med|sioux|dulu|aris|vslt|minneap|dako|twin"
echo "======================================================="
lynx -dump http://npsl.bonzidev.com/teams | egrep logo_ | egrep -i "$teamgrep" | cut -f3- -d[ | xargs -i echo Logo Link: {}
echo
lynx -dump http://npsl.bonzidev.com/teams | egrep sam.team | egrep -i "$teamgrep" | cut -f3 -d/ | cut -f1 -d. | xargs -i echo Team Link: {}
echo "======================================================="

process_args $@

[[ -z "$home" || -z "$visitor" ]] && { echo need to provide a --home and --visitor parameter with values ; exit 1 ; }

homedomain=`echo $home | tr -d _`
visitordomain=`echo $visitor | tr -d _`

homelink=`findTeamBonziLink $homedomain | egrep "findTeamBonziLink:" | cut -f2- -d:`
visitorlink=`findTeamBonziLink $visitordomain | egrep "findTeamBonziLink:" | cut -f2- -d:`

# The input can contain _, but remove for the bonzi team links
hometeamlogo=`findTeamLogo $home | egrep "findTeamLogo:" | cut -f2- -d: | tr -d ' '`
visitorteamlogo=`findTeamLogo $visitor | egrep "findTeamLogo:" | cut -f2- -d: | tr -d ' '`

echo Results:
echo $homelink $hometeamlogo
echo $visitorlink $visitorteamlogo

hometeamname=`echo $hometeamlogo | rev | cut -f1 -d'/' | rev | cut -f2- -d'_' | cut -f1 -d'.'`
visitorteamname=`echo $visitorteamlogo | rev | cut -f1 -d'/' | rev | cut -f2- -d'_' | cut -f1 -d'.'`

# TODO change to the call above for the real links
# homelink=http://medcityfc.bonzidev.com/sam/teams/index.php?team=3433240
# visitorlink=http://vsltfc.bonzidev.com/sam/teams/index.php?team=3426140 

hometeam=`fromlink $homelink`
visitorteam=`fromlink $visitorlink`

rm $currentgame # this should be the first writes to te file

# Base image link
echo "export baseimage=/mfcgameday/images" >> $currentgame
echo "export baseimagelink=https://s3.us-east-2.amazonaws.com$baseimage" >> $currentgame


echo "export hometeamname=\"$hometeamname\"" >> $currentgame
echo "export visitorteamname=\"$visitorteamname\"" >> $currentgame

echo "export hometeamlogo=$hometeamlogo" >> $currentgame
echo "export visitorteamlogo=$visitorteamlogo" >> $currentgame

echo "export hometeam=$hometeam" >> $currentgame
echo "export visitorteam=$visitorteam" >> $currentgame

homeroster=$data/$hometeam.roster
visitorroster=$data/$visitorteam.roster
echo "export homeroster=$data/$hometeam.roster" >> $currentgame
echo "export visitorroster=$data/$visitorteam.roster" >> $currentgame

echo "export homescoreboard=$data/$hometeam.scoreboard" >> $currentgame
echo "export visitorscoreboard=$data/$visitorteam.scoreboard" >> $currentgame

[[ -e "$homeroster" ]] && mv $homeroster $homeroster-`datestamp`
[[ -e "$visitorroster" ]] && mv $visitorroster $visitorroster-`datestamp`

buildRoster $homelink $homeroster
buildRoster $visitorlink $visitorroster

validateRoster $homeroster
validateRoster $visitorroster

trace x
