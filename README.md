
# Med City FC -- Game Day
 
![alt text](https://github.com/frankmalin/gameday/blob/master/image/Med%20City%20FC.png "Med City FC")


Game day is used for the MedCityFC soccer team to keep track of scoring.  
I have been scoring the games on paper, but found it to be to time consuming.  

The intent of game day is to 

 - Provide information required by the [league](http://npsl.bonzidev.com/teams ) of all the players on the team.

## game day sample output
 - [ html output ](https://s3.us-east-2.amazonaws.com/mfcgameday/currentgame/index.html)
 - [ json output ](https://s3.us-east-2.amazonaws.com/mfcgameday/currentgame/scoreboard.json)  

## for each game
 - Provide real time scoring
   - this could be accessed on the web
   - mobile app foundation
   - web casts
 - Identify on field players for the watching audience
 - Real time scoring of SOG, save, corners, penalties


### Why not use other scoring scheme
 - my budget precluded any software investment
 - the utility will pull the complete roster information from the npsl main site
 - I wanted to be able to manage the output, incase there was an error in the data
 - the first pass would be with an laptop/keyboard, but would like to provide a voice front end
 - the command line is simple, basically an action in the game which requires scoring can be done with 3 character
   - action
   - team 
   - player #
	- gh7 (goal home player #7), a background clock will score the game time
	- ih4 (sub in home player #4)

## Part

### Team Roster
Roster generator. NPLS lists all its team links on a common website, with a hint at the teams name, the scripts are able   
to navigate to the team's official league site, and pull the player information.  
This step can be done in advance of the game.  
The file is simply a list of player number and name.  
The file once generated, can be edited, which happens when the team does not have numbers for some players.  
The team roster consists of all the players on the team.

### Game Day Roster
The game day roster is generated from the team roster.  
The game day roster will identify the 11 starter, and 6 reserve players.  
Again, the game day roster can be edited by hand, if corrections need to be made, this is a simple text file.


### Game Day Stats
Once the game starts, the gameday command line can be used to score the game:
 - adjust the game clock
 - Shots
 - Shots on goal
 - Goals
 - assists
 - fouls
 - yellow cards
 - red cards
Ther is a game clock which is running as when the halfs are started, this will be used to log the game time an event occurs

### Timer
Background process which starts when you indicate the first or second half is stated.   
the clock can be adjusted if you have not started it at the correct time using a +seconds command

### Scoreboard
Up to the minute data will be collected using the underlying data files.  
The data will be formated sent to a static html file.  

An additional form, would be a json file, which could be processed in mobile apps for real time updates

### Real time scoring
The data will be pushed to an as yet to be determined cloud.   
that cloud will be used to display the static content.





