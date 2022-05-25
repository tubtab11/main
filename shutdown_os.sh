#!/bin/bash
#
# Purpose  : The purpose of this script will shutdown all databases listed in the oratab file
#
#            1.) shutdown OS.
#            2.) return status 0 completed.
# Change History:
#
# Version  Date      Who                  What
# -------- --------- -------- ----------------------------------------------------------------------
# 1.0.0    11 MAY 18 nattapon kuntaisong  Initial Release
#
#

export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d_%H%M%S")
LOG1=$LOGS/auto_shutdown_os_$NOW.log

#Reload profile
. ~/.profile


shut_ini()
{
    sudo init 5
    res=$?
    
    if [ $res -eq 0 ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Success to execute the init command" >> $LOG1
        exit 0
       
    else
        echo "$(date +"%Y%m%d%H%M%S") : Fail to execute the init command" >> $LOG1
        exit 101
    fi

}
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
    
    if [ $Mode == "normal" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Mode stop normal" >> $LOG1
        shut_ini

    else
        echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
        exit 255
    fi
####################################################
