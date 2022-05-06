#!/bin/bash

# Reload profile
. ~/.profile

export SCRIPT_DIR=/export/home/smsadmin/scripts
export LOG_DIR=/export/home/smsadmin/scripts/logs
export LOGS=/afc/ERGnrpe/logs

NOW=$(date +"%Y%m%d")
time=$(time +"%H%M%S")
LOG1=$LOGS/auto_shutdown_afc_$NOW+$time.log


stop_node()
{
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
        echo "kill Service [$service_name]" >> $LOG1
        echo "complated\n" >> $LOG1

  done
}
shutdown_status()
{
    value=`pmstatus.pl | grep 32m | egrep -v  "Process Manager Status" | egrep -v "no response" | cut -d ' ' -f2 | cut -c8-`
    if [ -z "$value" ]; 
    then
        echo "Service Shutdown Complated" >> $LOG1
        exit 0
    else
        echo "Service Shutdown Failed" >> $LOG1
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
echo "Node: $Node";
echo "Mode: $Mode";

#Check nodehealt of node type 
item=`nodehealth.sh|grep "Node Type" | nawk '{print $5}'|cut -c 2-4`

    if [ $Node == "$item" ]; 
    then
        echo "Node complated" >> $LOG1
    else
        echo "Node failed" >> $LOG1
        exit 0
    fi
    
        if [ $Mode == "force" ]; 
        then
            echo "Mode stop force" >> $LOG1
            check_ps
            shutdown_status
            exit 0
        elif [ $Mode == "normal" ]; 
        then
            echo "Mode stop normal" >> $LOG1
        else
            echo "Mode stop failed" >> $LOG1
            exit 0
        fi
############################
stop_node
sleep 1.0
check_ps
sleep 1.0
shutdown_status
################################################################################
