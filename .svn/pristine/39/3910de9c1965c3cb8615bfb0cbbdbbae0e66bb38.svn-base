#!/bin/bash
#####################################################
# Remote shutdown SunOS
# Script name : OFS_Remote_Shutdown_OS.sh
# Version  Date      Who             What
# -------- --------- --------------- ----------------
# 1.0.0    11 Sep 18 BPS Infra Team  Initial Release
#####################################################
export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d")
time=$(time +"%H%M%S")
LOG1=$LOGS/auto_shutdown_os_$NOW+$time.log

#Reload profile
. ~/.profile


# Check excecute with arguement.
while getopts n:m: flag
do
    case "${flag}" in
        n) Node=${OPTARG};;
        m) Mode=${OPTARG};;

    esac
done
echo "Node: $Node";
echo "Mode: $Mode";

#Check nodehealt of node type 
item=`nodehealth.sh|grep "Node Type" | nawk '{print $5}'|cut -c 2-4`

    if [ $Node == "$item" ]; 
    then
        echo "Node complated" >> $LOG1
    else
        echo "Node failed" >> $LOG1
        exit 1
    fi
    
        if [ $Mode == "force" ]; 
        then
            #Shutdown Solaris OS
            sudo poweroff
            #Return exit code
            exit 0
    
        elif [ $Mode == "normal" ]; 
        then
            echo "Mode stop normal" >> $LOG1
            #Shutdown Solaris OS
            init 5
            #Return exit code
            exit 0
        else
            echo "Mode stop failed" >> $LOG1
            exit 1
        fi
####################################################
