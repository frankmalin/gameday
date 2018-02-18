#+ cat /home/malin/github.com/gameday/bin/.//..//data/vsltfc.roster

# This is a set of common utilities
#
[[ `dirname $0 | cut -c1` = '/' ]] && bpath=`dirname $0`/ || bpath=`pwd`/`dirname $0`/
rpath=$bpath/../
props=$rpath/properties
data=$rpath/data
html=$rpath/html

currentgame=$data/gameday.properties
timefile=$data/timer.properties

function trace()
{
	local tracetype=""
	case $1 in
		e) tracetype="[ENTRY]"
		;;
		x) tracetype="[EXIT]"
		;;
		d) tracetype="[DEBUG]"
		;;
		i) tracetype="[INFO]"
		;;
		*) tracetype="[$1]"
	esac; shift
	local functionname=${FUNCNAME[*]}
	echo $tracetype `echo $0 | rev | cut -f1 -d/ | rev` $functionname $@
}


function process_args()
{

	while test $# -gt 0 
	do 
		echo $1 $2
		[[ $1 =~ ^-- ]] && { eval `echo $1 | cut -c3- | cut -f2 -d' '`="$2" ; shift 2; continue; }
		echo Unknown parm : $1 ; shift
	done
}

function fromlink()
{
	echo $1 | cut -f3 -d/ | cut -f1 -d.
}

timestr="time:"
function settime()
{
        # this will start the time
        local whichtime=$1
		
	# Should see if there is a timer running and kill it 
	ps -ef | egrep 99_timer.sh | egrep -v grep | tr -s ' ' | cut -f2 -d' ' | xargs -r kill -KILL  # kill any old timers laying around

        [[ $whichtime = 1 ]] && m=1 || m=45
        echo $timestr$m > $timefile
	$bpath/99_timer.sh & # batch out the time
}

function gettime()
{
	egrep $timestr $timefile | cut -f2 -d:
}

function writetime()
{
	# This is a setting from the time
	echo $timestr$1 > $timefile
}

function adjusttime()
{
	# set the adjustment to the time
	echo $1$2 >> $timefile
}

function readadjust() 
{
	# return the adjustment needed to the time
	egrep "\+|\-" $timefile
}

function datestamp()
{
	echo `date | tr ' ' '_' | tr ':' '-'`
}

function initeach()
{
	local whichboard=$1
	local teamname=$2
	local teamlogo=$3
	[[ -e "$whichboard" ]] && mv $whichboard $whichboard-`datestamp`

	echo team:`echo $teamname| tr '_' ' '` > $whichboard
	echo logo:$teamlogo >> $whichboard
	echo goals:0 >> $whichboard
	echo corners:0 >> $whichboard
        echo fouls:0 >> $whichboard
	echo shots:0 >> $whichboard
	echo saves:0 >> $whichboard
	echo cautions:0 >> $whichboard
	echo reds:0 >> $whichboard

}

function initscoreboards()
{
	initeach $homescoreboard $hometeamname $hometeamlogo
	initeach $awayscoreboard $awayteamname $awayteamlogo
}

function update()
{
	local team=$1
	local attribute=$2
	local scoreboard=${team}scoreboard
	[[ "$team" = "h" ]] && scoreboard=$homescoreboard || scoreboard=$awayscoreboard

	local linenum=`egrep -n "$attribute:" $scoreboard | cut -f1 -d':'`

	local value=`egrep "$attribute:" $scoreboard | cut -f2 -d':'`
	let value++
	let after=linenum-1

	sed -i "${linenum}s/.*/$attribute:$value/" $scoreboard
}

function updateMinutesPlayed()
{
	updateTeamMinutes h
	updateTeamMinutes a
}

function updateTeamMinutes() 
{
	# This will take in a roster, and will updates the minutes played
	local rosterP=$1

	local num=""
	local roster=""

        [[ "$rosterP" = "h" ]] && roster=$homeroster || roster=$awayroster

	trace e
	local currenttime=`gettime`
	if [ ! "$currenttime" = *"+"* ] ; then
		# Loop thru the players and update the time
		cat $roster | egrep "^\sS|^\sP" | cut -f2 | while read num
		do
			trace d "Read number: $num"
			playerread $rosterP $num
			let pm=currenttime-psi
			trace d "player minutes: $pm"
			playerwrite
			trace d "player write"
		done
	fi
	trace x

}

function playerlock()
{
	trace e
	while true
	do
		if mkdir $data/playerlock ; then
			trace i "Player daatabase LOCKED"
			break; # lock the entire player data
		else
			# TODO should add a kill here
			trace i "player database lock WAIT"
			sleep 1 # player lock sleep
		fi
	done
	trace x
}

function playerunlock()
{
	trace e
	rm -rf $data/playerlock # free up the lock for others
	trace x
}

# These are player fields
# we are single threaded, so can use global for these ... we expect to retrieve, update, write in a short period of time
pindex=""
pfile=""
pstatus=""
pnum=""
pname=""
pg=""
pm=""
psi=""
pso=""
py=""
pyr=""
pr=""
prr=""

function playerread()
{
	trace e
	local nolock=$1 # I think that we would need to do an unlock ... after the write of the data
# could produce a lock 
	[[ -z "$nolock" ]] && playerlock
	local rosterP=$1
	local number=$2

	local roster=""
	[[ "$rosterP" = "h" ]] && roster=$homeroster || roster=$awayroster

	# This will pull the player record from the roster with all the current information
	pfile=$roster
	pindex=`egrep -n "^\s\S\s$number\s" $roster | cut -f1 -d:` # this will find the player and the line number
	p=`egrep "^\s\S\s$number\s" $roster` 
	pstatus=`echo $p | tr -s ' ' | cut -f1 -d' '`
	pnum=`echo $p | tr -s ' ' | cut -f2 -d' '`
	pname=`echo $p | tr -s ' '| cut -f3 -d' '`
	pg=`echo $p | tr -s ' '| cut -f4 -d' '`
	pm=`echo $p | tr -s ' '| cut -f5 -d' '`
	psi=`echo $p | tr -s ' '| cut -f6 -d' '`
	pso=`echo $p | tr -s ' '| cut -f7 -d' '`
	py=`echo $p | tr -s ' '| cut -f8 -d' '`
	pyr=`echo $p | tr -s ' '| cut -f9 -d' '`
	pr=`echo $p | tr -s ' '| cut -f10 -d' '`
	prr=`echo $p | tr -s ' '| cut -f11 -d' '`
	trace x
}

function playerwrite()
{
	trace e
	local line="\t$pstatus\t$pnum\t$pname\t$pg\t$psi\t$pso\t$py\t$pyr\t$pr\t$prr"
        sed -i "${pindex}s/.*/$line/" $pfile
	playerunlock
	trace x
}

function updatePlayer()
{
	trace e
	local rosterP=$2
	local whichtable=$1
	shift; shift
	[[ $roster = "h" ]] && roster=$homeroster || roster=$awayroster
	echo "<!-- begin roster $rosterP for $whichtable -->" > $data/${rosterP}_${whichtable}
	[[ `egrep "^\s$whichtable\s" $roster` ]] && set `egrep "^\s$whichtable\s" $roster | cut -f3`
	while test $# -gt 0
	do
		playerHtmlRecord $rosterP $1 | egrep "playerHtmlRecord:" | cut -f2- -d':'  >> $data/${rosterP}_${whichtable}
		shift
	done 
	sed -i -e "/@@${rosterP}_${whichtable}@@/r $data/${rosterP}_${whichtable}" $html/index.html
	sed -i "/@@${rosterP}_${whichtable}@@/d" $html/index.html
	trace x
}

function playerHtmlRecord()
{
	local roster=$1
	local number=$2
	
	playerread $roster $number
	dpname=`echo $pname | tr _ ' '`
	returnR=`cat $html/$roster.player | sed  "s/@@pnum@@/$pnum/g; s/@@pname@@/$dpname/g; s/@@pg@@/$pg/g; s/@@pm@@/$pm/g; s/@@py@@/$py/g; s/@@pr@@/$pr/g"`
	echo "playerHtmlRecord:$returnR" # This is the return html recored with the updated customer
	playerunlock
}

function updateGoal()
{

        local roster=$1
        local number=$2
	local goaltime=$3
        
        playerread $roster $number
        pg=`echo "${pg}_${goaltime}" | sed "s/^0_//g"` # Need connector field
        playerwrite

}


function updateSubIn() 
{
	local roster=$1
	local number=$2
	local timein=$3
	
	playerread $roster $number
	psi=$timein
	pstatus='P'
	playerwrite
}

function updateSubOut()
{
	local roster=$1
	local number=$2
	local timeout=$3
	playerread $roster $number
	pso=$timeout
	pstatus='O'
	playerwrite
}

function updateYellow()
{
        local roster=$1
        local number=$2
        local timeof=$3
	local reason=$4
        playerread $roster $number
	py=$timeof
	pyr=$reason
	playerwrite
	# Need the mapping to H or A
	update $team cautions
}
function updateRed()
{
        local roster=$1
        local number=$2
        local timeof=$3
        local reason=$4
        platerread $roster $number
        pr=$timeof
        prr=$reason
        playerwrite
	# need mapping to H or A
	update $team reds
}


