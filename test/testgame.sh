#!/bin/bash
# set up the test roster from a saved roster
mkdir -p ../data/
cp data/medcityfc.roster ../data/medcityfc.roster
cp data/vsltfc.roster ../data/vsltfc.roster
cp data/gameday.properties ../data/gameday.properties

cd ../bin
set `cat ../test/test.in`
while test $# -gt 0
do
	./03_game_stats.sh $1
done 
