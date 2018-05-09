#!/bin/bashe
# 
# Starter shell to allow for file redirect
#
# 
[[ -f ../log/GameDay.Gui.log ]] && mv ../log/GameDay.Gui.log ../log/GameDay.Gui.log.`date | tr ' ' '_' | tr ':' '-'`
python ./GameDay.py 2>&1 | tee ../log/GameDay.Gui.log
