#
# This is a set of common utilities
#
function process_args()
{

	while test $# -gt 0 
	do 
		echo $1 $2
		[[ $1 =~ ^-- ]] && { eval `echo $1 | cut -c3- | cut -f2 -d' '`="$2" ; shift 2; continue; }
	done
}

function fromlink()
{
echo $1 | cut -f3 -d/ | cut -f1 -d.
}

timefile=./timer.properties
timestr="time:"
function settime()
{
        # this will start the time
        local whichtime=$1
		
	# Should see if there is a timer running and kill it 
	ps -ef | egrep timer.sh | egrep -v grep | tr -s ' ' | cut -f2 -d' ' | xargs -r kill -KILL  # kill any old timers laying around

        [[ $whichtime = 1 ]] && m=1 || m=45
        echo $timestr$m > $timefile
	./timer.sh & # batch out the time
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

hteam=./h.scoreboard
ateam=./a.scoreboard

function initeach()
{
	local whichboard=$1
	[[ -e "$whichboard" ]] && mv $whichboard $whichboard-`datestamp`

	echo goals:0 > $whichboard
	echo corners:0 >> $whichboard
        echo fouls:0 >> $whichboard
	echo shots:0 >> $whichboard
	echo saves:0 >> $whichboard
	echo cautions:0 >> $whichboard
	echo reds:0 >> $whichboard

}

function initscoreboards()
{
	initeach $hteam
	initeach $ateam
}

function update()
{
	local team=$1
	local attribute=$2

	local linenum=`egrep -n "$attribute:" ./$team.scoreboard | cut -f1 -d:`

	local value=`egrep "$attribute:" ./$team.scoreboard | cut -f2 -d:`
	let value++
	let after=linenum-1

	sed -i "${linenum}s/.*/$attribute:$value/" ./$team.scoreboard
}

# These are player fields
# we are single threaded, so can use global for these ... we expect to retrieve, update, write in a short period of time
pindex=""
pfile=""
pstatus=""
pnum=""
pname=""
psi=""
pso=""
py=""
pyr=""
pr=""
prr=""

function playerread()
{
# could produce a lock 
	local roster=./vslt.roster # $1
	local number=$2

	# This will pull the player record from the roster with all the current information
	pfile=$roster
	pindex=`egrep -n "^\s\S\s$number\s" $roster | cut -f1 -d:` # this will find the player and the line number
	p=`egrep "^\s\S\s$number\s" $roster` 
	pstatus=`echo $p | tr -s ' ' | cut -f1 -d' '`
	pnum=`echo $p | tr -s ' ' | cut -f2 -d' '`
	pname=`echo $p | tr -s ' '| cut -f3 -d' '`
	psi=`echo $p | tr -s ' '| cut -f4 -d' '`
	pso=`echo $p | tr -s ' '| cut -f5 -d' '`
	py=`echo $p | tr -s ' '| cut -f6 -d' '`
	pyr=`echo $p | tr -s ' '| cut -f7 -d' '`
	pr=`echo $p | tr -s ' '| cut -f8 -d' '`
	prr=`echo $p | tr -s ' '| cut -f9 -d' '`
}

function playerwrite()
{
set -x
	local line="\t$pstatus\t$pnum\t$pname\t$psi\t$pso\t$py\t$pyr\t$pr\t$prr"
        sed -i "${pindex}s/.*/$line/" $pfile

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
	platerread $roster $number
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
        platerread $roster $number
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


