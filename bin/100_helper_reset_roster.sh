#!/bin/bash
#
. `dirname $0`/00_utilities.sh

reset_roster=$1

shortname=$data/$reset_roster
shortnamePrev=$data/${reset_roster}-Previous

mv $shortname ${shortnamePrev}

cat $shortnamePrev | cut -f3,4 | xargs -i echo -e "\t{}" | sort -k1n > $shortname
