#
# This is a set of common utilities
#
[[ `dirname $0 | cut -c1` = '/' ]] && bpath=`dirname $0`/ || bpath=`pwd`/`dirname $0`/
rpath=$bpath/../
props=$rpath/properties
data=$rpath/data
html=$rpath/html
log=$rpath/log
json=$rpath/json

currentgame=$data/gameday.properties
timefile=$data/timer.properties

mkdir -p $data

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
pss=""



function trace()
{
	local inTrace=$1
	local tracetype=""
	local tabs=""

	[[ ! -d $log ]] && mkdir -p $log
	case $inTrace in
		e) tracetype="[ENTRY]"
		;;
		E) tracetype="[ERROR]"
		;;
		x) tracetype="[EXIT]"
		;;
		d) tracetype="[DEBUG]"
		;;
		i) tracetype="[INFO]"
		;;
		v) tracetype="[EVENT]"
		;;
		*) tracetype="[$1]"
	esac; shift
	## Get trace information and formatting
	echo -e "$tracetype\t`echo $0 | rev | cut -f1 -d/ | rev`\t`echo ${FUNCNAME[@]} | cut -f3- -d' ' | tr ' ' '\n' | xargs -i echo -n -e '\t{}' | tr -d  [:alnum:]`${FUNCNAME[1]} $@">> $log/ALL.log
	echo $@ >> $log/`echo $tracetype | cut -f2 -d'[' | cut -f1 -d']'`.log
	[[ "$inTrace" = "E" ]] && echo -e "$tracetype `echo $0 | rev | cut -f1 -d/ | rev` $functionname $@"
}

function teamname()
{
	local team=$1
	[[ "$team" = "h" ]] && echo $hometeamname || echo $visitorteamname
	
}

function playername()
{
	local team=$1
	local num=$2
	local roster=""
	[[ "$team" = "h" ]] && roster=$homeroster || roster=$visitorroster
	egrep "^\s.\s$num\s" $roster | cut -f4 | tr '_' ' '
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

function otherteam()
{
	[[ "$1" = "h" ]] && echo "v" || echo "h"
}

timestr="time:"
halfstr="half:"
running="running:"
function settime()
{
        # this will start the time
        local whichtime=$1
	local clockstate="stopped"

	case $whichtime in
		1) m=1
		   clockstate="running"
		;;
		2) m=46
		   clockstate="running"
		;;
		h) m="Halftime"
		;;
		e) m="Final"
		;;
		*) trace E "Invalid option: $whichtime"
	esac
        echo $timestr$m > $timefile
	echo $halfstr$whichtime >> $timefile
	echo $running$clockstate >> $timefile
	[[ $whichtime = "1" || $whichtime = "2" ]] && { ps -ef | egrep 99_timer.sh | egrep -v grep | tr -s ' ' | cut -f2 -d' '  | xargs -i -r kill -KILL {} ; $bpath/99_timer.sh & } 
}

function clockstate()
{
	echo `egrep "$running" $timefile | cut -f2 -d:`
}

function buildevent()
{
	# Build an event for logging
	local event=$1
	local time=$2
	local what="$3"

	echo $event: $what @$time
}

function buildevent()
{
	# Build an event for logging
	local event=$1
	local time=$2
	local what="$3"

	echo $event: $what @$time
}

function gettime()
{
	egrep $timestr $timefile | cut -f2 -d:
}

function gethalf()
{
	egrep $halfstr $timefile | cut -f2 -d:
}

function writetime()
{
	# This is a setting from the time
	echo $timestr$1 > $timefile
	echo $halfstr$2 >> $timefile
}

function adjusttime()
{
	# set the adjustment to the time
	echo $1$2 >> $timefile
}

function readadjust() 
{
	# return the adjustment needed to the time
	egrep "^\+|^\-" $timefile
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
	echo sog:0 >> $whichboard
	echo percent:0 >> $whichboard
	echo corners:0 >> $whichboard
	echo offsides:0 >> $whichboard
        echo fouls:0 >> $whichboard
	echo pk:0 >> $whichboard
	echo shots:0 >> $whichboard
	echo saves:0 >> $whichboard
	echo cautions:0 >> $whichboard
	echo reds:0 >> $whichboard

}

function initscoreboards()
{
	initeach $homescoreboard $hometeamname $hometeamlogo
	initeach $visitorscoreboard $visitorteamname $visitorteamlogo
}


function downdate() # reverse an action that was previously done
{
        local team=$1
        local attribute=$2
        local scoreboard=${team}scoreboard
        trace e $2
        [[ "$team" = "h" ]] && scoreboard=$homescoreboard || scoreboard=$visitorscoreboard

        local linenum=`egrep -n "$attribute:" $scoreboard | cut -f1 -d':'` || { trace E "Missing scoreboard attribute: $attribute" ; return 1 ; }

        local value=`egrep "$attribute:" $scoreboard | cut -f2 -d':'`
        let value--
        let after=linenum-1

        sed -i "${linenum}s/.*/$attribute:$value/" $scoreboard
        trace x
}

function update()
{
	local team=$1
	local attribute=$2
	local scoreboard=${team}scoreboard
	trace e $2
	[[ "$team" = "h" ]] && scoreboard=$homescoreboard || scoreboard=$visitorscoreboard

	# check to see if the attribute exists, and it is defined in the scoreboard
	[[ -z "$attribute" ]] && { trace E "Missing attribute in scoreboard for file update" ; return 1 ; }  
	egrep "$attribute:" $scoreboard || { trace E "Failed to find $attribute in $scoreboard, skipping update" ; return 1 ; }

	local linenum=`egrep -n "$attribute:" $scoreboard | cut -f1 -d':'` || { trace E "Missing scoreboard attribute: $attribute" ; return 1 ; }

	local value=`egrep "$attribute:" $scoreboard | cut -f2 -d':'`
	let value++
	let after=linenum-1
	cp $scoreboard $scoreboard-`date | tr ' ' '_' | tr ':' '-'`
	sed -i "${linenum}s/.*/$attribute:$value/" $scoreboard
	trace x
}

function updatePercent()
{
        local team=$1
        local percent=$2
	local attribute="percent"
	
        local scoreboard=${team}scoreboard
        trace e $2
        [[ "$team" = "h" ]] && scoreboard=$homescoreboard || scoreboard=$visitorscoreboard

        local linenum=`egrep -n "$attribute:" $scoreboard | cut -f1 -d':'` || { trace E "Missing scoreboard attribute: $attribute" ; return 1 ; }

        let after=linenum-1

        sed -i "${linenum}s/.*/$attribute:$percent/" $scoreboard
        trace x

}

function updateMinutesPlayed()
{
	updateTeamMinutes h
	updateTeamMinutes v
}

function updateTeamMinutes() 
{
	# This will take in a roster, and will updates the minutes played
	local rosterP=$1

	local num=""
	local roster=""

        [[ "$rosterP" = "h" ]] && roster=$homeroster || roster=$visitorroster

	trace e
	local currenttime=`gettime`
	if [[ `echo $currenttime | egrep '^[0-9]{1,2}$'` ]] ; then
		# Loop thru the players and update the time
		trace d "`egrep "^\sS\s" $roster | cut -f3`"
		set `egrep "^\sS\s" $roster | cut -f3`
		while test $# -gt 0
		do
			num=$1
			trace d "Read number: $num"
			playerread $rosterP $num
			let lpm=currenttime-psi
			pm=$lpm
			trace d "player minutes: $pm"
			playerwrite
			trace d "player write"
			shift
		done
	fi
	trace d "Exit $pm"
	trace x

}

function playerlock()
{
	trace e
	local playerlock=$1.lock
	local lockPid="X"
	local lockCount=0
	while true
	do
		if mkdir $data/$playerlock ; then
			trace i "Player database LOCKED : $playerlock, $BASHPID"
			touch $data/$playerlock/$BASHPID
			break; # lock the entire player data
		else
			trace i "pid : $BASHPID, waiting ($lockCount) on player database lock: $playerlock,  `ls -1 $data/$playerlock/`"
			# Check to see if the process which holds the lock exists
			[[ "`ls -1 $data/$playerlock/`" = "$lockPid" ]] && let lockCount+=1 || { lockCount=0 ; lockPid=`ls -1 $data/$playerlock/` ; }
			[[ `ps -ef | tr -s ' ' | cut -f2 -d' ' | egrep "$(ls -1 $data/$playerlock)"` ]] || rm -rf $data/$playerlock
			sleep 1 # player lock sleep
			[[ $lockCount -gt 100 ]] && rm -rf $data/$playerlock
		fi
	done
	trace x
}

function playerunlock()
{
	trace e 
	local playerlock=$1.lock
	trace i "Player database UNLOCKED : $playerlock, $BASHPID"
	rm -rf $data/$playerlock # free up the lock for others
	trace x
}

function playerread()
{
	trace e
	local nolock=$3 # I think that we would need to do an unlock ... after the write of the data
# could produce a lock 
	local rosterP=$1
	local number=$2

	local roster=""
	[[ "$rosterP" = "h" ]] && roster=$homeroster || roster=$visitorroster
        [[ -z "$nolock" ]] && playerlock `basename $roster`

	# This will pull the player record from the roster with all the current information
	pfile=$roster
	pindex=`egrep -n "^\s\S\s$number\s" $roster | cut -f1 -d:` # this will find the player and the line number
	p=`egrep "^\s\S\s$number\s" $roster` 
	trace i $p
	proster="R" # TODO add a field here
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
	pss=`echo $p | tr -s ' '| cut -f12 -d' '` # start status
trace d "$pstatus $pnum $pname $pg $pm ..."
	trace x
}

function playerwrite()
{
	trace e
	local line="\t$pstatus\t$pnum\t$pname\t$pg\t$pm\t$psi\t$pso\t$py\t$pyr\t$pr\t$prr\t$pss"
	trace d $line
	[[ -z "$pindex" || -z "pnum" ]] && { playerunlock `basename $pfile` ; trace E "Player index not set" ; return ; }
        sed -i "${pindex}s/.*/$line/" $pfile
	playerunlock `basename $pfile`
	trace x
}

function updatePlayer()
{
	trace e "$1 $2"
	local rosterP=$2
	local whichtable=$1
	shift; shift
	[[ $rosterP = "h" ]] && roster=$homeroster || roster=$visitorroster
	echo "<!-- begin roster $rosterP for $whichtable -->" > $data/${rosterP}_${whichtable}
	trace d  "egrep "^\s$whichtable\s" $roster  `egrep "^\s$whichtable\s" $roster | cut -f3`"
	[[ `egrep "^\s$whichtable\s" $roster` ]] && set `egrep "^\s$whichtable\s" $roster | cut -f3`
	while test $# -gt 0
	do
		playerHtmlRecord $rosterP $1 | egrep "playerHtmlRecord:" | cut -f2- -d':'  >> $data/${rosterP}_${whichtable}
		playerJsonRecord $rosterP $1 
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
	trace e $1 $2
	local returnR=""
	
	playerread $roster $number
	dpname=`echo $pname | tr _ ' '`
	returnR=`cat $html/$roster.player | sed  "s/@@pnum@@/$pnum/g; s/@@pname@@/$dpname/g; s/@@pg@@/$pg/g; s/@@pm@@/$pm/g; s/@@py@@/$py/g; s/@@pr@@/$pr/g"`
	echo "playerHtmlRecord:$returnR" # This is the return html recored with the updated customer
	playerunlock `basename $pfile`
	trace x
}

function playerJsonRecord()
{
        local roster=$1
        local number=$2
        trace e $1 $2

	local goalrecord=""
	local goaltemplate="{\"type\": \"@@type@@\",\"minute\": \"@@goalminute@@\"},"

        playerread $roster $number
        dpname=`echo $pname | tr _ ' '`
	if [[ "$pg" != "0" ]] ; then
		set `echo $pg | tr '_' ' '`
		while test $# -gt 0 
		do
			[[ "`echo $1 | egrep Own`" ]] && type="own" || type="goal"
			goalminute=`echo $1 | grep -Eo '[0-9]{1,2}'`
			goalrecord="$goalrecord `echo $goaltemplate | sed "s/@@type@@/$type/g; s/@@goalminute@@/$goalminute/g"` "
			shift
		done	
	fi
	goalrecord="`echo $goalrecord | rev | cut -c2- | rev`" # remove the last comma on the continuation 
	local fstatus=""
	case $pstatus in
		S) fstatus="PITCH"
			;;
		O) fstatus="OUT"
			;;
		R) fstatus="ROSTERED"
			;;
		N) fstatus="NOTROSTERED"
			;;
		*) trace E "Unknown status: $pstatus"
	esac
	local rstatus=""
	case $pss in
		S) rstatus="STARTED"
			;;
		R) rstatus="ROSTERED"
			;;
		N) rstatus="NOTROSTERED"
			;;
		*) trace E "Unknown roster state: $pss"
	esac
	local returnR=""
        returnR=`cat $json/roster.template | sed  "s/@@pnum@@/$pnum/g; s/@@pname@@/$dpname/g; s/@@pg@@/$pg/g; s/@@pm@@/$pm/g; s/@@py@@/$py/g; s/@@pr@@/$pr/g; s/@@pstatus@@/$fstatus/g; s/@@roster@@/$rstatus/g; s/@@goals@@/$goalrecord/g"`
        echo $returnR >> $json/$roster.json
        playerunlock `basename $pfile`
        trace x
}


function updateGoal()
{

        local roster=$1
        local number=$2
	local goaltime=$3
        
        playerread $roster $number
        pg=`echo "${pg}_@${goaltime}" | sed "s/^0_//g"` # Need connector field
        playerwrite

}


function updateSubIn() 
{
	local roster=$1
	local number=$2
	local timein=$3
	
	playerread $roster $number
	psi=$timein
	pstatus='S'
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
	py="@$timeof"
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
        playerread $roster $number
        pr="@$timeof"
        prr=$reason
        playerwrite
	# need mapping to H or A
	update $team reds
}


