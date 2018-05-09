#!/bin/bash
#
# This will be used to count the Time of possession
# In v1.0 of the application, it will use the count of total passes
#
# I do have data which should actual time of possession but will run post processing of the data
# to see how that aligns
#
set -x
data=../data/
function totalpasses()
{
        cat $data/possession | wc -l

}

function teampasses()
{
        local team=$1
        local teamabbr=`echo $team | cut -c1`
        egrep -c "${teamabbr}T" $data/possession

}

[[ ! -f "$data/possession" ]] && { echo "Failed to find possession file, none calculated" ; exit 1 ; }

tp=$((`totalpasses` ))
hpass=$((`teampasses home` * 100 ))
vpass=$((`teampasses visitor` * 100 ))

echo $hpass $vpass $tp
# Once calculated set the data parameters

echo $(($hpass / $tp )) >> $data/h.possession # write to the end of the file
echo $(($vpass / $tp )) >> $data/v.possession 
