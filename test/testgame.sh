#!/bin/bash
# set up the test roster from a saved roster
cp ../data/medcityfc.roster.save ../data/medcityfc.roster
cp ../data/vsltfc.roster.save ../data/vsltfc.roster

cd ../bin
./03_game_stats.sh < ../test/test.in
