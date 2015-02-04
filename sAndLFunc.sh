#!/bin/bash
#Luke Curtis (LC422)
#Operating Systems 2 - ASSIGNMENT
#sAndLFunc.sh
#2014-2015
function runSAL {
	echo -e "\nScan & Look Simulation started" #echo all search seek access and blocks $1 = SSA $2 = BLOCKS
	seek=`echo $1 | cut -f1 -d','`
	search=`echo $1 | cut -f2 -d','`
	access=`echo $1 | cut -f3 -d','`
	echo "Seek time is $seek"
	echo "Search time is $search"
	echo "Access time is $access"
	echo "List of blocks are as follows (access to individual blocks are accessible here)"
	echo $2 | tr ',' '\n' | while read block; do
   		echo "$block"
	done
	sleep 1
	echo "Scan & Look completed!"
	echo "Press any key to return to the menu..."
	read padding #this is essentially used to buffer the time so the usage.db logs more than a second
	sleep 1
	clear
}  
