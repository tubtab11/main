#!/bin/bash
#####################################################
# Remote shutdown non-global zones
# Script name : OFS_Remote_Shutdown_Zone.sh
# Version  Date      Who             What
# -------- --------- --------------- ----------------
# 1.0.0    11 Sep 18 BPS Infra Team  Initial Release
#####################################################
export LOGS=/afc/ERGnrpe/logs

#Reload profile
. ~/.profile

NOW=$(date +"%Y%m%d_%H%M%S")
LOG1=$LOGS/auto_shutdown_zone_$NOW.log

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
        exit 0
    else
        echo "$(date +"%Y%m%d%H%M%S") : Node failed" >> $LOG1
        exit 255
    fi
    
        if [ $Mode == "normal" ]; 
        then
            echo "$(date +"%Y%m%d%H%M%S") : Node stop complated" >> $LOG1
            exit 0
        else
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
            exit 255
        fi
#Halt all non-global zone
for i in `zoneadm list -v | awk '{print $2}'| grep -v NAME | grep -v global`
do
  #echo $i
  zoneadm -z $i halt
done

#Check have only one global zone
chk_zone=`zoneadm list -v | awk '{print $2}'| grep -v NAME`
if [ $chk_zone == "global" ]; then
  #shutdown non-zone completed
  echo "$(date +"%Y%m%d%H%M%S") : shutdown non-zone completed $chk_zone " >> $LOG1
  exit 0 
else
  #shutdown non-zone not completed
  echo "$(date +"%Y%m%d%H%M%S") : shutdown non-zone not completed $chk_zone" >> $LOG1
  exit 1
fi
#####################################################
