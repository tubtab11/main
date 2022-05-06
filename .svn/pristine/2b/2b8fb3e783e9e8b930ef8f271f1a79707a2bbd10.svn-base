#!/bin/bash
#####################################################
# Remote shutdown non-global zones
# Script name : OFS_Remote_Shutdown_Zone.sh
# Version  Date      Who             What
# -------- --------- --------------- ----------------
# 1.0.0    11 Sep 18 BPS Infra Team  Initial Release
#####################################################
export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d")
time=$(time +"%H%M%S")
LOG1=$LOGS/auto_shutdown_zone_$NOW+$time.log
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
    
        if [ $Mode == "normal" ]; 
        then
            echo "Node stop complated" >> $LOG1
        else
            echo "Mode stop failed" >> $LOG1
            exit 1
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
  echo "shutdown non-zone completed $chk_zone " >> $LOG1
  exit 0 
else
  #shutdown non-zone not completed
  echo "shutdown non-zone not completed $chk_zone" >> $LOG1
  exit 1
fi
#####################################################
