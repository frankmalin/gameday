#!/bin/bash
#
# This is used to show
#

# map the home and visitor parameter to the correct team roster
#set -x
. `dirname $0`/00_utilities.sh

. $currentgame

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
		local s=`echo $line | cut -f1 -d' '`
		sed -i "s#$line#$line\t0\t0\t0\t0\t0\t0\t0\t0\t0\t$s#g" $file
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

function validate()
{
	local file=$1; shift
	local failed=0

	set `echo $@`
	while test $# -gt 0
	do
		egrep -w "$1" $file > /dev/null || { echo "Player $1, not found in $file" ; failed=1 ; }
		shift
	done
	return $failed
}

team=""
rosternums=""
starternums=""
state=""

while test $# -gt 0; do
	[[ $1 =~ ^-h|--home$ ]] && { team=home ; shift 1 ; continue ; };
	[[ $1 =~ ^-a|--visitor$ ]] && { team=visitor ; shift 1 ; continue ; };
	[[ $1 =~ ^-r|--roster$ ]] && { state="roster"; shift 1; continue; };
        [[ $1 =~ ^-s|--start$ ]] && { state="start" ; shift 1; continue; };
	[[ "$state" = "roster" ]] && rosternums="$rosternums $1" || starternums="$starternums $1"
	shift
done

[[ -z "$team" ]] && { echo Need to set--home or --visitor ; exit 1 ; } 

echo r: $rosternums
echo s: $starternums

[[ "$team" = "home" ]] && roster=$homeroster || roster=$visitorroster

validate $roster $rosternums || exit 1
validate $roster $starternums || exit 1

# Process the stating numbers

processRoster $roster R $rosternums
processRoster $roster S $starternums
nonRoster $roster

sed -i "s/\t\t/\t/g" $roster



