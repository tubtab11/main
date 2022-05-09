#!/bin/bash
#
# Program  : remote_shutdown_oracledb.sh
#
# Purpose  : The purpose of this script will shutdown all databases listed in the oratab file
#
#            1.) Input parameter no need
#            2.) Stop listener
#            3.) Kill pending process
#            4.) Stop Database
#            5.) return status 0 completed.
# Change History:
#
# Version  Date      Who      What
# -------- --------- -------- ----------------------------------------------------------------------
# 1.0.0    11 Sep 18 NatthawutP  Initial Release
#
#
. ~/.profile

##### Environment Variable, User must configure to match with the target oracle server. ####
export ORACLE_SID=CCSPROD1
export ORACLE_BASE=/app/oracle
export ORACLE_HOME=/app/oracle/product/server_ee/19.5.0.0
export PATH=$PATH:$ORACLE_HOME/bin
export ORATAB=/var/opt/oracle/oratab
export TMP=/tmp

export SCRIPT_DIR=$ORACLE_BASE/admin/$ORACLE_SID/scripts/
export LOG_DIR=$ORACLE_BASE/admin/$ORACLE_SID/scripts/logs
############################################################################################

NOW=$(date +"%Y%m%d_%H%M%S")
LOG=$LOG_DIR/auto_shutdb_$NOW.log
ORACLE_INITD=/app/oracle/ofsdb/init.d

force_shut()
{
  ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
  if [ "$ORACLE_SID" = '*' ] ; then
    ORACLE_SID=""
  fi
# Called programs use same database ID
export ORACLE_SID
ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
export ORACLE_HOME
# Put $ORACLE_HOME/bin into PATH and export.
PATH=$ORACLE_HOME/bin:/bin:/usr/bin:/etc ; export PATH

PROCESS_PMON=$(ps -ef | grep "pmon" |grep $ORACLE_SID | grep -v "grep" | wc -l)
   if [ $PROCESS_PMON -ge 1 ];
   then
SQLDBA="sqlplus /nolog"
$SQLDBA <<EOF>>$LOG1
connect / as sysdba
shutdown abort
quit
EOF
   fi
}

#==========================
# M A I N
#==========================
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
item="ofs"

    if [ $Node == "$item" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Node complated" >> $LOG1
    else
        echo "$(date +"%Y%m%d%H%M%S") : Node failed" >> $LOG1
        exit 1
    fi
    
        if [ $Mode == "force" ]; 
        then
            echo "Mode stop force"
            force_shut >> $LOG1
            
        elif [ $Mode == "normal" ]; 
        then
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop normal" >> $LOG1
        else
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
            exit 1
        fi

#### Stop Database #######
$ORACLE_INITD/dbshut >> $LOG1
echo "$LOG1"

#### Check Database was down ######
 PROCESS_NUM=$(ps -ef | grep "pmon" | grep -v "grep" | wc -l)

        if [ $PROCESS_NUM -ge 1 ];
        then
        cat $ORATAB | while read LINE
            do
              case $LINE in
              \#*)                ;;        #comment-line in oratab
              *)
              ORACLE_SID=`echo $LINE | awk -F: '{print $1}' -`
              if [ "$ORACLE_SID" = '*' ] ; then
              # NULL SID - ignore
              ORACLE_SID=""
              continue
              fi
              # Proceed only if last field is 'Y' or 'W'
              if [ "`echo $LINE | awk -F: '{print $NF}' -`" = "Y" ] ; then
                 if [ `echo $ORACLE_SID | cut -b 1` != '+' ]; then
                 ORACLE_HOME=`echo $LINE | awk -F: '{print $2}' -`
                 force_shut >> $LOG1
                 fi
              fi
              ;;
              esac
            done
        echo "$(date +"%Y%m%d%H%M%S") :SHUTDOWN FORCE" >>$LOG1
        exit 0
        else
        echo "$(date +"%Y%m%d%H%M%S") :SHUTDOWN SMOOTH" >>$LOG1
        exit 0
        fi

