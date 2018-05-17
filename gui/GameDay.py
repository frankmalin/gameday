import sys
import time

import subprocess # This is the subprocess to make the bash

from PyQt4 import QtGui, QtCore

global home
home="Home"
global visitor
visitor="Visitor"

class Window(QtGui.QMainWindow):
    
    # Team Direction
    teamR="Home"
    teamL="Visitor"

    currentPossession="Home"

    def __init__(self):
        super(Window, self).__init__()
        self.setGeometry(50, 50, 1200, 600)
        self.setWindowTitle("Med City FC Game Day")
        self.setWindowIcon(QtGui.QIcon('../image/Med City FC.png'))
        self.home()

###############################################################
#
#   Define all the QPushButtons used in the description of the
#   Field and action buttons. Every button make a call to a
#   specific subroutine
#
###############################################################
    def home(self):

        homeSubButIn = QtGui.QPushButton("Sub H", self)
        homeSubButIn.clicked.connect(self.sub_home)
        homeSubButIn.resize(60,40)
        homeSubButIn.move(10,10)
	# Yellow
        homeYellow = QtGui.QPushButton("Yellow", self)
       	homeYellow.clicked.connect(self.yellow_home)
        homeYellow.resize(60,20)
        homeYellow.move(10,50)
	# Red
        homeRed = QtGui.QPushButton("Red", self)
        homeRed.clicked.connect(self.red_home)
        homeRed.resize(60,20)
        homeRed.move(10,70)
        # GOAL 
        homeGoal = QtGui.QPushButton("Goal", self)
        homeGoal.clicked.connect(self.goal_home)
        homeGoal.resize(60,20)
        homeGoal.move(10,90)
        # Assist
        homeAssist = QtGui.QPushButton("Assist", self)
        homeAssist.clicked.connect(self.assist_home)
        homeAssist.resize(60,20)
        homeAssist.move(10,110)
	# Own
        homeOwn = QtGui.QPushButton("Own", self)
        homeOwn.clicked.connect(self.own_home)
        homeOwn.resize(60,20)
        homeOwn.move(10,130)
        # Waveoff 
        homeDisallow = QtGui.QPushButton("Disallow", self)
        homeDisallow.clicked.connect(self.disallow_home)
        homeDisallow.resize(60,20)
        homeDisallow.move(10,150)

	# Visitor
        visitorSubButIn = QtGui.QPushButton("Sub V", self)
        visitorSubButIn.clicked.connect(self.sub_visitor)
        visitorSubButIn.resize(60,40)
        visitorSubButIn.move(110,10)
        # Yellow
        visitorYellow = QtGui.QPushButton("Yellow", self)
        visitorYellow.clicked.connect(self.yellow_visitor)
        visitorYellow.resize(60,20)
        visitorYellow.move(110,50)
        # Red
        visitorRed = QtGui.QPushButton("Red", self)
        visitorRed.clicked.connect(self.red_visitor)
        visitorRed.resize(60,20)
        visitorRed.move(110,70)
        # GOAL
        visitorGoal = QtGui.QPushButton("Goal", self)
        visitorGoal.clicked.connect(self.goal_visitor)
        visitorGoal.resize(60,20)
        visitorGoal.move(110,90)
        # Assist
        visitorAssist = QtGui.QPushButton("Assist", self)
        visitorAssist.clicked.connect(self.assist_visitor)
        visitorAssist.resize(60,20)
        visitorAssist.move(110,110)
        # Own
        visitorOwn = QtGui.QPushButton("Own", self)
        visitorOwn.clicked.connect(self.own_visitor)
        visitorOwn.resize(60,20)
        visitorOwn.move(110,130)
        # Waveoff
        visitorDisallow = QtGui.QPushButton("Disallow", self)
        visitorDisallow.clicked.connect(self.disallow_visitor)
        visitorDisallow.resize(60,20)
        visitorDisallow.move(110,150)

	# Add in the text box for sub
	global inTextbox
	inTextbox = QtGui.QLineEdit(self)
	inTextbox.setStyleSheet("color: green;")
	inTextbox.move(70,10)
	inTextbox.resize(40,20)

        global outTextbox
        outTextbox = QtGui.QLineEdit(self)
	outTextbox.setStyleSheet("color: red;")
        outTextbox.move(70,30)
        outTextbox.resize(40,20)

	global otherTextbox # This is used to score most other events requiring a player
        otherTextbox = QtGui.QLineEdit(self)
        otherTextbox.move(70,70)
        otherTextbox.resize(40,20)


	# Setup the clock
	# start clock
        homeOffSide = QtGui.QPushButton("OffSide", self)
        homeOffSide.clicked.connect(self.offsides_home)
        homeOffSide.resize(60,20)
        homeOffSide.move(10,170)
	
	# end first
        visitorOffSide = QtGui.QPushButton("OffSide", self)
        visitorOffSide.clicked.connect(self.offsides_visitor)
        visitorOffSide.resize(60,20)
        visitorOffSide.move(110,170)

        # start clock
        homePK = QtGui.QPushButton("PK", self)
        homePK.clicked.connect(self.pk_home)
        homePK.resize(60,20)
        homePK.move(10,190)

        # end first
        visitorPK = QtGui.QPushButton("PK", self)
        visitorPK.clicked.connect(self.pk_visitor)
        visitorPK.resize(60,20)
        visitorPK.move(110,190)


	# Team actions
	# offside	

       # start clock
	global clockStart
        clockStart = QtGui.QPushButton("Start", self)
        clockStart.clicked.connect(self.clock_start)
        clockStart.resize(60,20)
        clockStart.move(10,220)

        # end first
	global clockHalf
        clockHalf = QtGui.QPushButton("Halftime", self)
	clockHalf.setEnabled(False)
        clockHalf.clicked.connect(self.clock_half)
        clockHalf.resize(60,20)
        clockHalf.move(110,220)

	# Re-enable, this will enable all the buttons on a mistake
        clockEnable = QtGui.QPushButton("Reset", self)
        clockEnable.clicked.connect(self.clock_enable)
        clockEnable.resize(30,20)
        clockEnable.move(70,240)


        # start second
	global clockSecond
        clockSecond = QtGui.QPushButton("Second", self)
	clockSecond.setEnabled(False)
        clockSecond.clicked.connect(self.clock_second_half)
        clockSecond.resize(60,20)
        clockSecond.move(10,240)

        # end game
	global clockEnd
        clockEnd = QtGui.QPushButton("Game", self)
	clockEnd.setEnabled(False)
        clockEnd.clicked.connect(self.clock_end)
        clockEnd.resize(60,20)
        clockEnd.move(110,240)
	
	global directionHome
        directionHome = QtGui.QPushButton(self.direction_string_home(), self)
        directionHome.clicked.connect(self.team_toggle)
        directionHome.resize(60,20)
        directionHome.move(10,280)

	global directionVisitor
        directionVisitor = QtGui.QPushButton(self.direction_string_visitor(), self)
        directionVisitor.clicked.connect(self.team_toggle)
        directionVisitor.resize(60,20)
        directionVisitor.move(110,280)

	# This is to show a snippet of the index file
	global snippet
	snippet = QtGui.QPushButton("Index", self)
	snippet.clicked.connect(self.snippet_index)
	snippet.resize(60,20)
	snippet.move(10, 320)

        global snippetBox 
        snippetBox = QtGui.QLineEdit(self)
        snippetBox.setStyleSheet("color: blue;")
	snippetBox.setReadOnly(True)
        snippetBox.move(10,340)
        snippetBox.resize(100,20)

	# Field Action
	# Defensive Zone
	global topLZone
	topLZone = QtGui.QPushButton("Home zone"+self.direction_string_home(), self)
	topLZone.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: #0ff808 }"
			    "QPushButton { font: bold 18px }" )

        topLZone.clicked.connect(self.zone_top_left)
        topLZone.resize(400,140)
        topLZone.move(300, 70)

	global topRZone
        topRZone = QtGui.QPushButton("Home zone"+self.direction_string_home(), self)
        topRZone.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: #0ff808 }"
			    "QPushButton { font: bold 18px }" )
        topRZone.clicked.connect(self.zone_top_right)
        topRZone.resize(400,140)
        topRZone.move(700, 70)

	global lowerLZone
        lowerLZone = QtGui.QPushButton("Visitor zone >>>", self)
        lowerLZone.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: #0ff808 }"
			    "QPushButton { font: bold 18px }")
        lowerLZone.clicked.connect(self.zone_lower_left)
        lowerLZone.resize(400,140)
        lowerLZone.move(300, 310)

	global lowerRZone
        lowerRZone = QtGui.QPushButton("Visitor zone >>>", self)
        lowerRZone.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: #0ff808 }"
			    "QPushButton { font: bold 18px }")
        lowerRZone.clicked.connect(self.zone_lower_right)
        lowerRZone.resize(400,140)
        lowerRZone.move(700, 310)
	

	# Out of Bounds (2)
        topOut = QtGui.QPushButton("Out of Bounds", self)
        topOut.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        topOut.clicked.connect(self.out_top)
        topOut.resize(800,50)
        topOut.move(300, 20)

        lowerOut = QtGui.QPushButton("Out of Bounds", self)
        lowerOut.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        lowerOut.clicked.connect(self.out_lower)
        lowerOut.resize(800,50)
        lowerOut.move(300,450)



	# In Bounds (not needed)
	# Tackle Away (2)
        topTackle = QtGui.QPushButton("Tackle", self)
        topTackle.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: yellow }")
        topTackle.clicked.connect(self.tackle)
        topTackle.resize(600,50)
        topTackle.move(400, 210)

        lowerPass = QtGui.QPushButton("Interception", self)
        lowerPass.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: #ff00ff }")
        lowerPass.clicked.connect(self.interception)
        lowerPass.resize(600,50)
        lowerPass.move(400, 260)
        # start second
        topPenalty = QtGui.QPushButton("Penalty Home", self)
        topPenalty.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: red }")
        topPenalty.clicked.connect(self.penalty_home)
        topPenalty.resize(100,20)
        topPenalty.move(650,200)

        # end game
        lowerPenalty = QtGui.QPushButton("Penalty Vistor", self)
        lowerPenalty.setStyleSheet("QPushButton { background-color: #148A36 }"
                            "QPushButton:hover { background-color: red }")
        lowerPenalty.clicked.connect(self.penalty_visitor)
        lowerPenalty.resize(100,20)
        lowerPenalty.move(650,300)

	
	# Shot(2)
        shotL = QtGui.QPushButton("shot", self)
        shotL.setStyleSheet("QPushButton { background-color: #3d8a14 }"
                            "QPushButton:hover { background-color: #14698a }")

        shotL.clicked.connect(self.shot_left)
        shotL.resize(100,200)
        shotL.move(300,170)

        shotR = QtGui.QPushButton("shot", self)
        shotR.setStyleSheet("QPushButton { background-color: #3d8a14 }"
                            "QPushButton:hover { background-color: #14698a }")

        shotR.clicked.connect(self.shot_right)
        shotR.resize(100,200)
        shotR.move(1000,170)


	# Save(2)
        saveL = QtGui.QPushButton("Save", self)
        saveL.setStyleSheet("QPushButton { background-color: #c2b9b8 }"
                            "QPushButton:hover { background-color: #e63f39 }")
        saveL.clicked.connect(self.save_left)
        saveL.resize(50,80)
        saveL.move(250,220)

        saveR = QtGui.QPushButton("Save", self)
        saveR.setStyleSheet("QPushButton { background-color: #c2b9b8 }"
                            "QPushButton:hover { background-color: #e63f39 }")
        saveR.clicked.connect(self.save_right)
        saveR.resize(50,80)
        saveR.move(1100,220)

        goalL = QtGui.QPushButton("G", self)
        goalL.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: red }")
        goalL.clicked.connect(self.goal_left)
        goalL.resize(20,80)
        goalL.move(230,220)

        goalR = QtGui.QPushButton("G", self)
        goalR.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: red }")
        goalR.clicked.connect(self.goal_right)
        goalR.resize(20,80)
        goalR.move(1150,220)


	# Corner(4)
        cornerTL = QtGui.QPushButton("C", self)
        cornerTL.setStyleSheet("QPushButton { background-color: #f2efe6 }"
                            "QPushButton:hover { background-color: yellow }")
        cornerTL.clicked.connect(self.corner_left)
        cornerTL.resize(50,50)
        cornerTL.move(250, 20)

        cornerTR = QtGui.QPushButton("C", self)
        cornerTR.setStyleSheet("QPushButton { background-color: #f2efe6 }"
                            "QPushButton:hover { background-color: yellow }")
        cornerTR.clicked.connect(self.corner_right)
        cornerTR.resize(50,50)
        cornerTR.move(1100, 20)

        cornerLL = QtGui.QPushButton("C", self)
        cornerLL.setStyleSheet("QPushButton { background-color: #f2efe6 }"
                            "QPushButton:hover { background-color: yellow }")
        cornerLL.clicked.connect(self.corner_left)
        cornerLL.resize(50,50)
        cornerLL.move(250, 450)

        cornerLR = QtGui.QPushButton("C", self)        
	cornerLR.setStyleSheet("QPushButton { background-color: #f2efe6 }"
                            "QPushButton:hover { background-color: yellow }")
        cornerLR.clicked.connect(self.corner_right)
        cornerLR.resize(50,50)
        cornerLR.move(1100, 450)

	# Goal kick(4)
        goalkickTL = QtGui.QPushButton("GK", self)
        goalkickTL.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        goalkickTL.clicked.connect(self.goalkick_left)
        goalkickTL.resize(50,150)
        goalkickTL.move(250, 70)

        goalkickLL = QtGui.QPushButton("GK", self)
        goalkickLL.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        goalkickLL.clicked.connect(self.goalkick_left)
        goalkickLL.resize(50,150)
        goalkickLL.move(250, 300)


        goalkickTR = QtGui.QPushButton("GK", self)
        goalkickTR.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        goalkickTR.clicked.connect(self.goalkick_right)
        goalkickTR.resize(50,150)
        goalkickTR.move(1100, 70)

        goalkickLR = QtGui.QPushButton("GK", self)
        goalkickLR.setStyleSheet("QPushButton { background-color: white }"
                            "QPushButton:hover { background-color: #c3c4b1 }")
        goalkickLR.clicked.connect(self.goalkick_right)
        goalkickLR.resize(50,150)
        goalkickLR.move(1100, 300)

        self.show()

##############################################################################
#  
#   Define the button specific actions to the pushed buttone
#   In most cases, there is a call to a generic button with
#   the team specified as a paramter
#
##############################################################################
 
    def team_direction(self):
	print("team")

    def team_toggle(self):
    	print("Toggle teams")
        left=self.teamR
 	self.teamR=self.teamL
	self.teamL=left
	directionHome.setText(self.direction_string_home())
	directionVisitor.setText(self.direction_string_visitor())
	topRZone.setText("MedCity FC"+self.direction_string_home())
	topLZone.setText("MedCity FC"+self.direction_string_home())
	lowerLZone.setText("Visitor"+self.direction_string_visitor())
	lowerRZone.setText("Visitor"+self.direction_string_visitor())

    def direction_string_home(self):
       	if self.teamR == "Home":
	   return "<<<"
 	else:
	   return ">>>"


    def direction_string_visitor(self):
	if self.teamR == "Visitor":
	   return "<<<"
	else:
	   return ">>>"

    def team_right(self):
	return self.teamR

    def team_left(self):
	return self.team
   
    def offsides_home(self):
	self.offsides("Home")

    def offsides_visitor(self):
	self.offsides("Visitor")

    def offsides(self, team):
	print("Offsides: "+team)
	self.command("u"+self.who_action(team)+otherTextbox.displayText())

    def pk_home(self):
        self.pk("Home")

    def pk_visitor(self):
        self.pk("Visitor")

    def pk(self, team):
        print("Penalty Kick: "+team)
        self.command("P"+self.who_action(team)+otherTextbox.displayText())

    def yellow_home(self):
       	self.yellow(home)
    def red_home(self):
   	self.red(home)
    def goal_home(self):
	self.goal_credit(home)
    def assist_home(self):
	self.goal_assist(home)
    def own_home(self):
	self.own(home)
    def disallow_home(self):
	self.disallow(home)

    def yellow_visitor(self):
        self.yellow(visitor)
    def red_visitor(self):
        self.red(visitor)
    def goal_visitor(self):
        self.goal_credit(visitor)
    def assist_visitor(self):
        self.goal_assist(visitor)
    def own_visitor(self): 
        self.own(visitor)
    def disallow_visitor(self):
	self.disallow(visitor)

    def yellow(self, team):
	print("Yellow: "+team+"number: "+otherTextbox.displayText())	
	self.command("y"+self.who_action(team)+otherTextbox.displayText())
	otherTextbox.setText("")
    def red(self, team):
        print("red: "+team+"number: "+otherTextbox.displayText())
	self.command("r"+self.who_action(team)+otherTextbox.displayText())
        otherTextbox.setText("")

    def goal_credit(self, team):
        print("goal: "+team+"number: "+otherTextbox.displayText())
	self.command("g"+self.who_action(team)+otherTextbox.displayText())
        otherTextbox.setText("")

    def goal_assist(self, team):
        print("assist: "+team+"number: "+otherTextbox.displayText())
	self.command("a"+self.who_action(team)+otherTextbox.displayText())
        otherTextbox.setText("")

    def own(self, team):
        print("own: "+team+"number: "+otherTextbox.displayText())
	self.command("O"+self.who_action(team)+otherTextbox.displayText())
	otherTextbox.setText("")


    def disallow(self, team):
	print("disallow: "+team)
	self.command("d"+self.who_action(team))


    def sub_home(self):
        self.sub_player("home", inTextbox.displayText(), outTextbox.displayText())
	inTextbox.setText("")
	outTextbox.setText("")

    def snippet_index(self):
	# This is a snippet of the html which is being produced
	file = open("../html/index.txt", "r") 
	line=file.read()
	snippetBox.setText(line)
	self.command("C")


    def sub_visitor(self):
        self.sub_player("visitor", inTextbox.displayText(), outTextbox.displayText())
        inTextbox.setText("")
        outTextbox.setText("")

    def who_action(self, team):
	C=team[0]
	c=C.lower()	
	print("Character = "+str(c))
	return c

    def sub_player(self, team, playerIn, playerOut):
        print("Sub player "+team+" "+playerIn+", "+playerOut)
	print("Command : I"+self.who_action(team)+playerIn)
	print("Command : O"+self.who_action(team)+playerOut)	
	self.command("i"+self.who_action(team)+playerIn)
	self.command("o"+self.who_action(team)+playerOut)

    def switch_possession(self):
	# This is the change from who has the possession to a new possession
	if self.currentPossession == "Home":
	   self.currentPossession="Visitor"
	else:
	   self.currentPossession="Home"
	return self.currentPossession

    def tackle(self):
	print("Tackle: "+self.switch_possession()) # need to calculate team posession
	print("Time:Tackle:touch:"+self.currentPossession+":"+self.timestamp())

    def interception(self):
	print("Interception: "+self.switch_possession())
	print("Time:Intercept:touch:"+self.currentPossession+":"+self.timestamp())

    # shot
    def shot_right(self):
	print("Shot right")
	self.shot(self.teamL)

    def shot_left(self):
	print("Shot Left")
	self.shot(self.teamR)

    def shot(self, team):
	print("shot:"+team)
	print("Time:Shot:noop:"+team+":"+self.timestamp())
	self.command("s"+self.who_action(team))
    
    # save
    def save_right(self):
	print("Save Right")
	self.save(self.teamR)

    def save_left(self):
        print("Save Left")
	# set team
	self.save(self.teamL)

    def save(self, team):
	print("Save team:"+team)
	print("Time:Save:noop:"+team+":"+self.timestamp())
	self.command("S"+self.who_action(team))

    def goal_right(self):
        self.goal(self.teamL)

    def goal_left(self):
        self.goal(self.teamR)

    def goal(self, team):
        print("Goal:"+team)
	print("Time:Goal:stop:"+team+":"+self.timestamp())
	self.command("G"+self.who_action(team))

    def timestamp(self):
	string_value1 = str(time.time())
	return string_value1 

   # Clock
    def clock_start(self):
	clockHalf.setEnabled(True)
	clockStart.setEnabled(False)
	self.command("1")

    def clock_half(self):
	clockHalf.setEnabled(False)
	clockSecond.setEnabled(True)
	self.command("h");

    def clock_enable(self):
	clockStart.setEnabled(True)
	clockHalf.setEnabled(True)
	clockSecond.setEnabled(True)
	clockEnd.setEnabled(True)

    def clock_second_half(self):
	clockSecond.setEnabled(False)
	clockEnd.setEnabled(True)
	self.command("2")

    def clock_end(self):
	clockEnd.setEnabled(False)
	self.command("E")

    #goalkick 
    def goalkick_right(self):
	self.goalkick(self.teamR)

    def goalkick_left(self):
   	self.goalkick(self.teamL)

    def goalkick(self, team):
	print("Goal Kick:"+team)
	print("Time:Goalkick:stop:"+team+":"+self.timestamp())
	self.command("k"+self.who_action(team))

    def penalty_home(self):
	print("Penalty:Home")
	self.penalty(home)
    def penalty_visitor(self):
	print("Penalty:Visitor")
	self.penalty(visitor)
    def penalty(self, team):
	self.command("f"+self.who_action(team))

    # Out
    def out_top(self):
    	self.out()

    def out_lower(self):
	self.out()

    def out(self):
	# This will stop the clock, and will start a new possession
	print("Out, Throw in")
	print("Time:Out:stop::"+self.timestamp())

    def corner_right(self):
	self.corner(self.teamL)

    def corner_left(self):
	self.corner(self.teamR)

    def corner(self, team):
	print("Corner Kick:"+team)
	print("Time:Corner:stop:"+team+":"+self.timestamp())
	self.command("c"+self.who_action(team))

    def which_zone(self, whichTeam, whichOne):
 	if (( whichOne == "right" and whichTeam == self.teamR ) or ( whichOne == "left" and whichTeam == self.teamL )):
		return "defense"
	else:
		return "offense"

    def zone_top_left(self):
	self.zone("Home", self.which_zone("Home", "left"))
    def zone_top_right(self):
	self.zone("Home", self.which_zone("Home", "right"))
    def zone_lower_left(self):
	self.zone("Visitor", self.which_zone("Visitor", "left"))
    def zone_lower_right(self):
	self.zone("Visitor", self.which_zone("Visitor", "right"))
    def zone(self, team, quadrant):
	print("Posession: "+team+" in "+quadrant)
	self.currentPossession=team
	print("Time:Zone"+quadrant+":touch:"+team+":"+self.timestamp())

    def command(self, whichCommand):
	print("Command to run: "+whichCommand)
	subprocess.call(["../bin/03_game_stats.sh", whichCommand])
        
def run():
    app = QtGui.QApplication(sys.argv)
    app.setStyleSheet('QMainWindow{background-color: gray;border: 1px solid black;}')
    GUI = Window()
    sys.exit(app.exec_())

run()
