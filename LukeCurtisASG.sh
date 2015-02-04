#!/bin/bash
#Luke Curtis (LC422)
#Operating Systems 2 - ASSIGNMENT
#LukeCurtisASG.sh
#2014-2015
source fcfsFunc.sh #import external shell functions
source sstfFunc.sh
source sAndLFunc.sh
source effects.sh
source colours.sh

currentUsername=$1

#begin assignment 2 variables

blocks="null"
seek="null"
search="null"
access="null"

dateLogged="null"
dateLoggedInSec="null"
dateOff="null"
dateOffInSec="null"
#BEGIN METHODS
function exitTest {
        echo "Are you sure you want to exit[Y/n]?" #double checks if user wants to quit program
        read doubleCheck
        continueRegEx='^[Nn]$'
        if [[ $doubleCheck =~ $regex ]]
        then #checks if it is Y/y/N/n and is only 1 char in reg exp
            echo "Exiting application!"
            logoffDetails
            sleep 1
            clear
            exit 0 #exit application if Bye is typed
        elif [[ $doubleCheck =~ $continueRegEx ]]
        then
            echo "Continuing..."
            sleep 1
        else
            echo "Invalid entry, please try again"
            exitTest
        fi
}
function checkUser {
        currentUsername=$1
        checkUserExists=$(cat /etc/passwd | grep "^$currentUsername\b" | cut -d":" -f1) #greps user to see if they exist and then an if statement to verify
       
        if [ -z $checkUserExists ]
        then 
            return 1 #returns one if no results for user found, otherwise, 0 returned, meaning success
        fi
        currentUserFullName=$(cat /etc/passwd | grep $1 | cut -d":" -f5 |  sed 's/,,,//') #gets full name by grepping in /etc/passwd and sed to exclude commas
        return 0
}
function logonDetails {
            #add details to the usage db in correct format add "CURRENTLY LOGGED"/ "NOSIMUSED" / "TOTTIMENA" for appendage later
            #when user logs out, uses a sim, or calculates time
            dateLogged=$(date)
            dateLoggedInSec=$(date +"%s")
            echo -e $currentUsername"\t\t"$dateLogged"\t\t""CURRENTLYLOGGED\t\tNoSimUsed\t\tTotTimeNA" >> usage.db  #append name to db
            return 0
}
function logoffDetails {
        #use SED to change the date logged off, and then get the logon time, and off in seconds, take them away and SED into usage.db
        dateOff=$(date)
        sed -i "s,CURRENTLYLOGGED,$dateOff,g" usage.db
        return 0
}
function logSimUsage {
        dateOffInSec=$(date +"%s")
        timeDiff=$(($dateOffInSec-$dateLoggedInSec))
        timeString="$(($timeDiff / 60))m $(($timeDiff % 60))s"
        sed -i "s,TotTimeNA,$timeString,g" usage.db
}
function appendLogs {
        sed -i "s,NoSimUsed,$1,g" usage.db
        #need to make seperate entry if they used a different simulator
        return 0
}
function mainMenu {
        shopt -s nocasematch; #disable case awareness for bye command
        let doubleCheck="null" #starter variable to ensure while loop is interpreted
        clear
        echo -e "$COL_RED Welcome $currentUserFullName $COL_RESET"
        regex='^[Yy]$' #regex to compare against when going back into while loop to make sure they didn't press Y to quit
        while  [[  !( $doubleCheck =~ $regex ) ]] #keeps looping until user types "Bye!" to exit simulation
        do
            echo -e "\nPlease enter your option ($COL_CYAN 1)FCFS $COL_RESET, $COL_GREEN 2)SSTF $COL_RESET or $COL_YELLOW 3)'SCAN & LOOK' $COL_RESET) or type Bye! to exit\n"
            read response
            case $response in
                1|"FCFS")
                    #Chosen this
                    logonDetails #in short, this process logs when/who used this sim (no other details)
                    getHDD 
                    getBlocks 
                    runEffects 
                    appendLogs "FCFS" #then appends the usage db with what they used in appendLogs function
                    runFCFS $seek,$search,$access $blocks
                    logSimUsage  #then finally logs time used for the sim ONLY (log off time is used only when application exits)
                    #this is then repeated for all simualtors
                    ;;
                2|"SSTF")
                    #Chosen this
                    logonDetails
                    getHDD
                    getBlocks
                    runEffects
                    appendLogs "SSTF"
                    runSSTF $seek,$search,$access $blocks
                    logSimUsage
                    ;;
                3|SCAN*)
                    #Chosen this
                    logonDetails
                    getHDD
                    getBlocks
                    runEffects
                    appendLogs "SAL"
                    runSAL $seek,$search,$access $blocks
                    logSimUsage
                    ;;
                bye|bye!)
                    #Chosen this
                    exitTest
                    ;;
                *)
           		   echo "Invalid response, please try again"
                    ;;
                esac
        done
        shopt -u nocasematch; #re-enable case sensitivity
}

function getHDD {
    #finds if the HDD config file exists, then splits it stores in variables, if not, ask user
    if [ -f hdd.config ]
    then
        seek=$(cat hdd.config | cut -f1 -d',')
        search=$(cat hdd.config | cut -f2 -d',')
        access=$(cat hdd.config | cut -f3 -d',')
    else
        echo "HDD Config file not found, please enter seek time"
        read seek
        echo "Now enter search time"
        read search
        echo "Finally, please enter access time"
        read access
    fi
}

function getBlocks {
    #finds if the blocks config file exists, stores it in a CSV format, if not, ask user for CSV format input 
    if [ -f blocks.config ]
    then
        tempBlocks=$(cat blocks.config)
    else
        echo "No block configuration found, please enter the blocks, COMMA SEPERATED"
        echo "e.g. 1,54,12,59,29"
        read tempBlocks
    fi
    blocks=$tempBlocks
}
#END METHODS

#####################################MAIN PROGRAM BEGIN#########################################
################################################################################################
if [ -z "$currentUsername" ];
then #if no name entered as argv then chance to enter here, otherwise goes to next
	echo "Username not entered on entry, please enter username to verify"
    read currentUsername
    if checkUser $currentUsername;
    then
       	mainMenu
    else
        echo "Bad Credentials - Entry Denied"
    fi
elif checkUser $currentUsername;
then
	mainMenu	
else
	clear
	echo "Bad Credentials - Entry Denied"
fi
exit 0