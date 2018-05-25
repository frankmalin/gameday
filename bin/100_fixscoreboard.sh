#!/bin/bash
#
. `dirname $0`/00_utilities.sh
. "$data/gameday.properties"


set -x
scoreboard=""
attr=""
value=""
sb=""

scoreboard=`cut -c2- <<< $1` ; shift; 

process_args $@ # This will process the args

[[ -z "$scoreboard" || -z "$attr" ]] && { echo "ERROR: Need to specify --home|--visitor --attr attribute --value value" ; exit 1 ; }

[[ "$scoreboard" = "home" ]] && sb=$homescoreboard || sb=$visitorscoreboard

# If the value is not set, assume a -1 on the value
[[ "`egrep -c "$attr.*:" $sb`" = "1" ]] && echo "Found attribute" || { echo "ERROR: Failed to find a single attr : $attr" ; exit 1 ; }
[[ -z "$value" ]] && { value=`egrep "$attr.*:" $sb | cut -f2 -d:` ; let "value--" ; } 
fullname=`egrep "$attr.*:" $sb | cut -f1 -d:`
echo set $fullname to $value
sed -i "s/$fullname:.*/$fullname:$value/g" $sb
cat $sb
