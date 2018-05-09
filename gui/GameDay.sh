#!/bin/bash
# 
# Starter shell to allow for file redirect
#
# 
[[ -d ../log/ ]] && { mv ../log ../log-`date | tr ' ' '_' | tr ':' '-'` ; mkdir ../log ; }
python ./GameDay.py | tee ../log/GameDay.Gui.log
