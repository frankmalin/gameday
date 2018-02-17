#!/bin/bash
#
# this will be called every minute to produce some form of an update
#
. `dirname $0`/99_utilities.sh

# Make the call to update the minutes played.
updateMinutesPlayed

# Update the scoreboard

# push the data to the static web server

