#!/bin/bash
#####################################################
# Remote shutdown SunOS
# Script name : OFS_Remote_Shutdown_OS.sh
# Version  Date      Who             What
# -------- --------- --------------- ----------------
# 1.0.0    11 Sep 18 BPS Infra Team  Initial Release
#####################################################
export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d_%H%M%S")
LOG1=$LOGS/auto_shutdown_os_$NOW.log

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
echo "$(date +"%Y%m%d%H%M%S") Node: $Node"; >> $LOG1
echo "$(date +"%Y%m%d%H%M%S") Mode: $Mode"; >> $LOG1

#Check nodehealt of node type 
item=`nodehealth.sh|grep "Node Type" | nawk '{print $5}'|cut -c 2-4`

    if [ $Node == "$item" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Node complated" >> $LOG1
       
    else
        echo "$(date +"%Y%m%d%H%M%S") : Node failed" >> $LOG1
        exit 255
    fi
    
        if [ $Mode == "force" ]; 
        then
            #Shutdown Solaris OS
            sudo poweroff
            #Return exit code
            
    
        elif [ $Mode == "normal" ]; 
        then
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop normal" >> $LOG1
            #Shutdown Solaris OS
            init 5
            #Return exit code
    
        else
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
            exit 255
        fi
####################################################
