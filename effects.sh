#!/bin/bash
#Luke Curtis (LC422)
#Operating Systems 2 - ASSIGNMENT
#effects.sh
#2014-2015
function runEffects {
	clear
	let x=1
	echo "Loading application" 
	for x in 1 2 3 4 5 6 7 8 9 10
	do
		printf "$COL_MAGENTA | $COL_RESET"
		
		sleep 0.1	
	done
	clear
}
