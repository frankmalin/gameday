#!/bin/bash
#
# This is used to show
#

# map the home and visitor parameter to the correct team roster
# set -x
. `dirname $0`/00_utilities.sh

. $currentgame

startlimit=11
rosterlimit=7

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
	local limit=$1; shift
	local whichset=$1; shift
	local failed=0
	local count=0
	egrep -q "0.*0.*0" $file && { mv $file ${file}-Previous ; cat ${file}-Previous | cut -f3,4 | xargs -i echo -e "\t{}" | sort -k1n > $file ; echo "Reformat file" ; }
	echo "If team has a non-standard line up, starting 10, with no sub, or less than 7 subs, use : --skipvalidate"
	# check to see if the file format is okay
	egrep "000" $file && { echo "ERROR: found player in $1 with number 000, please fix number" ; failed=1 ; }
	[[ `cat $file | cut -f2 | wc -l` = `cat $file | cut -f2 | sort -u | wc -l` ]] || { echo "ERROR: Duplicate number found, cat $file | sort -k1n"; failed=1; }
	set `echo $@`
	while test $# -gt 0
	do
		egrep -w "$1" $file > /dev/null || { echo "ERROR: Player $1 for $whichset, not found in $file" ; failed=1 ; }
		let count++
		shift
	done
	[[ ! "$limit" = "$count" ]] && { echo "ERROR: There were $count players for $whichset, expected $limit" ; failed=1 ; }
	
	[[ ! "$failed" = "0" && $validate = false ]] && { echo "Error found, but continueing"; failed=0; }
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
	[[ $1 =~ ^-n|--skipvalidate$ ]] && { validate=false ; shift 1; continue; };
	[[ "$state" = "roster" ]] && rosternums="$rosternums $1" || starternums="$starternums $1"
	shift
done

[[ -z "$team" || -z "$rosternums" || -z "$starternums" ]] && { echo Need to set--home or --visitor, --start nums, --roster nums ; exit 1 ; } 

echo r: $rosternums
echo s: $starternums

[[ "$team" = "home" ]] && roster=$homeroster || roster=$visitorroster

validate $roster $startlimit Starters $starternums || exit 1
validate $roster $rosterlimit Rostered $rosternums || exit 1

# Process the stating numbers

processRoster $roster R $rosternums
processRoster $roster S $starternums
nonRoster $roster

sed -i "s/\t\t/\t/g" $roster



