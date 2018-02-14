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
set -x

[[ `dirname $0 | cut -c1` = '/' ]] && bpath=`dirname $0`/ || bpath=`pwd`/`dirname $0`/
rpath=$bpath/../
props=$rpath/properties
data=$rpath/data
reports=$rpath/html


. $bpath/utilities.sh

function findTeamBonziLink() {
local teamName=$1
local teamLink=`lynx -dump http://npsl.bonzidev.com/teams | egrep sam.team | egrep -i "$teamName" | tr -s ' ' | cut -f3 -d' ' | tr ' ' '\n'` # try to find only one link
[[ `echo $teamLink | wc -l` -eq 1 ]] && echo findTeamBonziLink: $teamLink || { echo error, too many or too few links for : $teamName, result: $teamLink ; exit 1 ; }


}
function buildRoster()
{
local link=$1 # this is the link for the team
local teamroster=$2
rm $teamroster.raw 2>/dev/null || true
# TODO The web page may be free formatted, which may mean that the schedule is not next ... the code should be such that it loops thru, until the first non blank first character
set `lynx -dump $link | xargs -i echo "@{}@" | tr -s ' ' | tr ' ' '_' | egrep -A40 "@Roster@$" `
shift; shift # get past the first two lines
while test $# -gt 0
do
	# This is a parse of the output
	[[ `echo $1 | egrep "^@[0-9]"` || `echo $1 | egrep "^@.*_.*@$"` ]] && echo good || { echo end of roster ; break ; } 
	[[ `echo $1 | egrep "^@[0-9]"` ]] && { number=`echo $1 | cut -c2- | cut -f1 -d'_'` ; ncut=2 ; } || { number=000 ; ncut=1 ; }	
	name=`echo $1 | cut -c2- | cut -f${ncut}- -d'_' | tr '_' ' ' | rev | cut -c2- | rev`
	echo -e  "\t$number\t$name" >> $teamroster.raw
	shift
done
cat $teamroster.raw | sort -k1n > $teamroster

}

home=""
away=""
homeroster=""
awayroster=""

process_args $@

[[ -z "$home" || -z "$away" ]] && { echo need to provide a --home and --away parameter with values ; exit 1 ; }

homelink=`findTeamBonziLink $home | egrep "findTeamBonziLink:" | cut -f2- -d:`
awaylink=`findTeamBonziLink $away | egrep "findTeamBonziLink:" | cut -f2- -d:`

# TODO change to the call above for the real links
homelink=http://medcityfc.bonzidev.com/sam/teams/index.php?team=3433240
awaylink=http://vsltfc.bonzidev.com/sam/teams/index.php?team=3426140 

hometeam=`fromlink $homelink`
awayteam=`fromlink $awaylink`

homeroster=$data/$hometeam.roster
awayroster=$data/$awayteam.roster
[[ -e "$homeroster" ]] && mv $homeroster $homeroster-`datestamp`
[[ -e "$awayroster" ]] && mv $awayroster $awayroster-`datestamp`

buildRoster $homelink $homeroster
buildRoster $awaylink $awayroster


cat $homeroster
cat $awayroster

# Need to feed this into a web page to allow selection of starters
