#!/bin/bash
# 
# Starter shell to allow for file redirect
#
# 
[[ -d ../log/ ]] && { mv ../log ../log-`date | tr ' ' '_' | tr ':' '-'` ; mkdir ../log ; }
mkdir ../log/
touch ../log/GameDay.Gui.log
cd ../gui/
python ./GameDay.py | tee ../log/GameDay.Gui.log
