#!/bin/bash
#
# This is used to show
#

# map the home and away parameter to the correct team roster
#set -x
team=$1 ; shift
roster=$team.roster

function nonRoster()
{
	local file=$1 ; shift
	local line=""
	cat $file | while read line
	do
		[[ `echo $line | egrep -w "^R|^S"` ]] && echo $line true || sed -i "s#$line#N\t$line#g" $file
	done

	## Add in the remainder of the fields
	cat $file | while read line
	do
		sed -i "s#$line#$line\t0\t0\t0\t0\t0\t0#g" $file
	done
}


function processRoster()
{
	local file=$1 ; shift
	local whattype=$1 ; shift

	set `echo $@`
	while test $# -gt 0
	do
        	line=`grep -w "$1" $file`
		sed -i "s#$line#\t$whattype\t$line#g" $file
        	shift
	done
}

rosternums=""
starternums=""
state=""

while test $# -gt 0; do
	[[ $1 =~ ^-r|--roster$ ]] && { state="roster"; shift 1; continue; };
        [[ $1 =~ ^-s|--start$ ]] && { state="start" ; shift 1; continue; };
	[[ "$state" = "roster" ]] && rosternums="$rosternums $1" || starternums="$starternums $1"
	shift
done
echo r: $rosternums
echo s: $starternums

# Process the stating numbers

processRoster $roster R $rosternums
processRoster $roster S $starternums
nonRoster $roster

sed -i "s/\t\t/\t/g" $roster



