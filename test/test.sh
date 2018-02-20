#!/bin/bash
./01_pull_roster.sh --home med --away vslt
./02_gameday_roster.sh --home --start 1 2 3 4 6 7 8 9 10 11 21 --roster 13 14 15 16 17 25
./02_gameday_roster.sh --away --start 1 2 3 4 5 6 7 8 9 10 11 --roster 13 14 15 16 17 18

