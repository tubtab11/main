#!/bin/bash

# Reload profile
. ~/.profile

export SCRIPT_DIR=/export/home/smsadmin/scripts
export LOG_DIR=/export/home/smsadmin/scripts/logs
export PATH_OLS=/afc/ergols/scripts
export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d_%H%M%S")
LOG1=$LOGS/auto_shutdown_afc_$NOW.log

stop_node()
{   
  sudo -u ols $PATH_OLS/ols stop
  sudo nodecontrol.sh stop
  echo "$(date +"%Y%m%d%H%M%S") : nodecontrol stop" >> $LOG1
}
check_ps()
{
  value=`pmstatus.pl | grep 32m | egrep -v  "Process Manager Status" | egrep -v "no response" | cut -d ' ' -f2 | cut -c8-`
  declare -a my_array
  my_array=($value)

  for ((i=0; i < ${#my_array[@]}; i++ ));
  do
        service_name="${my_array[$i]}"
        sudo pkill -9 $service_name
        echo "$(date +"%Y%m%d%H%M%S") : kill Service [$service_name]" >> $LOG1
        echo "$(date +"%Y%m%d%H%M%S") : complated\n" >> $LOG1

  done
}
shutdown_status()
{
    value=`pmstatus.pl | grep 32m | egrep -v  "Process Manager Status" | egrep -v "no response" | cut -d ' ' -f2 | cut -c8-`
    if [ -z "$value" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Service Shutdown Complated" >> $LOG1
        exit 0
    else
        echo "$(date +"%Y%m%d%H%M%S") : Service Shutdown Failed" >> $LOG1
        exit 1
    fi
}
# ==========================
# M A I N
# ==========================

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
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop force" >> $LOG1
            check_ps
            shutdown_status
            exit 0

        elif [ $Mode == "normal" ]; 
        then
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop normal" >> $LOG1
        else
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
            exit 255
        fi
############################
stop_node
sleep 1.0
check_ps
sleep 1.0
shutdown_status
#############################
