#!/bin/bash
#Luke Curtis (LC422)
#Operating Systems 2 - ASSIGNMENT
#LukeCurtisASG.sh
#2014-2015

#BEGIN METHODS
function getTimes {
	#choice is passed over, what was selected either username or simulator, or null if cumulative usage
	choice=$1 #if null, then cat the usage for all minutes and seconds in the db, else, gets same but only lines with sim/username
	if [ -z "$choice" ];
	then
		listOfSeconds=$(cat usage.db | cut -f9 -s | cut -d' ' -f2 | sed 's/s//g')
		listOfMinutes=$(cat usage.db | cut -f9 -s | cut -d' ' -f1 | sed 's/m//g')
	else
		listOfSeconds=$(cat usage.db | grep "$choice" | cut -f9 -s | cut -d' ' -f2 | sed 's/s//g')
		listOfMinutes=$(cat usage.db | grep "$choice" | cut -f9 -s | cut -d' ' -f1 | sed 's/m//g')
	fi
	numSeconds=0 #set these to nothing to return later when they have the times in them.
	numMinutes=0
	numHours=0
	while read numSec; do #reverse redirect to the list of seconds to go through
        for (( i=0;i<numSec;i++ ))
        do
        	#for each number that was grep'ed in usage it has to go through each time to make sure that the seconds don't exceed 60
        	#when it does, add a minute to it
        	numSeconds=$(($numSeconds+1))
        	if (( $numSeconds >= 60 ));
        	then
        		numMinutes=$((numMinutes+1))
        		numSeconds=0 #reset num seconds to 0 before reading next number
        		if (( $numMinutes >= 60 ));
				then
					#if (unlikely) the minutes are at 60, add and hour, and reset
        			numHours=$((numHours + 1))
        			numMinutes=0
        		fi
        	fi
        done
	done <<< "$listOfSeconds" #reverse redirect to the list of seconds to go through

	while read numMin; do #exactly the same process here, but for minutes
		for (( x=0;x<numMin;x++ ))
		do
			if (( $numMin > 0 ));
			then
				numMinutes=$(($numMinutes+1))
        		if (( $numMinutes >= 60 ));
				then
        			numHours=$((numHours + 1))
        			numMinutes=0
        		fi
        	fi
        done
	done <<< "$listOfMinutes"
	#put all the results in a string, and echo out for usage.
	local totTimeString="$numHours h $numMinutes m $numSeconds s"
	echo "$totTimeString"
}
function makeChoice {
	echo "Please enter:"
	echo "1) Specific username for entire time using simulator"
	echo "2) All users combined time using simulator"
	echo "3) A specific sim time usage"
	echo "4) Exit log simulation"
	read choice #read the choice wanted, case statement, which will then prompt for username or sim
	case $choice in
		1)
			#validateUser
			echo "Please enter the username you would like to view cumulative time for"
			read tempUserName
			userName=$(echo "$tempUserName" | tr '[:upper:]' '[:lower:]') #convert to lower to grep the usage db make sure so no error
			userValid=$(cat usage.db | grep "^$userName\b" | cut -f1 -s) #finds user and validates if they exist in usage.db
			if [ -z "$userValid" ];
			then
				echo "User not found, try again." #if no returned values then gets here, user not found
			else
				echo "Total time usage for $userName is"
				getTimes $userName
			fi
			;;
		2)
			echo "Calculating total sim time usage..."
			sleep 1
			echo "Total time usage is:"
			getTimes
			;;
		3)
			echo "Please enter the simualtion you would like to view cumulative time for (FCFS/SSTF/SAL ONLY)"
			read tempSimulator
			simulator=$(echo "$tempSimulator" | tr '[:lower:]' '[:upper:]') #convert to upper, just incase (Stored in db in uppercase)
			echo "Total time usage for $simulator is"
			getTimes $simulator
			;;
		4)
			echo "Exiting application"
			sleep 1
			clear
			exit 0
			;;
		*)
	        echo "Invalid response, please try again"
	        ;;
		esac
	echo "Press any key to proceed"
	read buffer
	clear
}
######BEGIN MAIN FUNCTION#######
while true
do
	makeChoice
done
exit 0