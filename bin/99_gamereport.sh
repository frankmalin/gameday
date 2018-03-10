#!/bin/bash
#
# This is called at the end of the game to generate the game report
#
set -x
. `dirname $0`/00_utilities.sh

. $currentgame


function generateTeam()
{
	local rosterP=$1
        local htmlrecord="<tr><td>@@pnum@@</td><td>@@pname@@</td><td>@@notrostered@@</td><td>@@started@@</td><td>@@reserve@@</td><td>@@pm@@</td><td>@@psi@@</td><td>@@pso@@</td><td>@@pg@@</td><td>@@PYR@@</td><td>@@py@@</td><td>@@PRR@@</td><td>@@pr@@</td></tr>"


	[[ "$rosterP" = "h" ]] && roster=$homeroster || roster=$visitorroster

	rm $html/teamdata.html 2>/dev/null
	local s=""
	local r=""
	local n=""
	sed -i "s/@@${rosterP}_teamname@@/`teamname $rosterP`/" $html/game.html # Update the team
	# TODO update the score
	# count the number of reads
	# count the number of yellows
	cat $roster | cut -f3 | while read num; do
		s=""; r=""; n=""
		playerread $rosterP $num
		[[ "$pyr" != "0" ]] && PYR=`egrep " $pyr/.*(ylw)" $props/game_stats.properties | cut -f1 -d'(' | cut -f2 -d'/'` || PYR=''
                [[ "$prr" != "0" ]] && PRR=`egrep " $prr/.*(red)" $props/game_stats.properties | cut -f1 -d'(' | cut -f2 -d'/'` || PRR=''
		case $pss in
			S) s="X"; 
				;;
			R) r="X"
				;;
			N) n="X"
				;;
			*) s="?"; n="?"; r="?"
		esac
		echo $htmlrecord | sed "s/@@pnum@@/$pnum/; s/@@pname@@/$pname/; s/@@notrostered@@/$n/; s/@@started@@/$s/; s/@@reserve@@/$r/; s/@@pm@@/$pm/; s/@@psi@@/$psi/; s/@@pso@@/$pso/; s/@@pg@@/$pg/; s/@@PYR@@/$PYR/; s/@@py@@/$py/; s/@@PRR@@/$PRR/; s/@@pr@@/$pr/" >> $html/teamdata.html
		playerunlock # There should not be any play ocntention at this time
	done	
	sed -i -e "/@@${rosterP}_TEAMDATA@@/r $html/teamdata.html" $html/game.html
	sed -i "/@@${rosterP}_TEAMDATA@@/d" $html/game.html

}
function teamUpdate()
{
	local teamP=$1
        [[ $teamP = "h" ]] && scoreboard=$homescoreboard || scoreboard=$visitorscoreboard

        cat $scoreboard | while read line
        do
                name=`echo $line | cut -f1 -d':'`
                value=`echo $line | cut -f2- -d':'`
                sed -i "s#@@${teamP}_${name}@@#$value#g" $html/game.html
        done

}

function startReport()
{
	local teamP=$1
	cp $html/game.template $html/game.html
	
	sed -i "s/@@DATE@@/`date | tr -s ' ' | cut -f1-3,6 -d' '`/" $html/game.html

	teamUpdate h
	teamUpdate v
}

function uploadReport()
{
 	echo We can optionally upload the report
}

startReport
generateTeam h
generateTeam v
uploadReport


