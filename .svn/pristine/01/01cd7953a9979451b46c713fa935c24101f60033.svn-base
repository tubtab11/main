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
export LOGS=/afc/ERGnrpe/logs
############################################################################################

NOW=$(date +"%Y%m%d")
time=$(time +"%H%M%S")
TMP_ACTIVE_SESS_FILE=$TMP/kill_active_session.sql
LOG=$LOG_DIR/auto_kill_sesions_$NOW+$time.log
LOG1=$LOGS/auto_kill_sesions_$NOW+$time.log
ORACLE_INITD=/app/oracle/ofsdb/init.d

kill_session()
#========================
## Function Kill Pending User on Database ##
{
rm -f $TMP_ACTIVE_SESS_FILE
sqlplus -s /nolog <<EOF>$TMP_ACTIVE_SESS_FILE
set echo on
set feedback off
set define off
set linesize 500
set pagesize 800
set sqlprompt ''
set heading off
--set sqlnumber off
connect / as sysdba
SELECT 'ALTER SYSTEM KILL SESSION '||''''|| s.SID||','||s.SERIAL#||''''||';' as script
FROM gv\$session s
WHERE s.STATUS = 'ACTIVE'
and s.username is not null
and s.username not in ('SYS','SYSTEM');
exit;
EOF

sqlplus -s "/as sysdba" < $TMP_ACTIVE_SESS_FILE >> $LOG
echo "$LOG"

if [ $? == "0" ];
then
    sqlplus -s "/as sysdba" < $TMP_ACTIVE_SESS_FILE >> $LOG1
    echo "Connect Database Complated" >> $LOG1

    if [ $? == "0" ]
    then 
        echo "Status connect complated" >> $LOG1
        exit 0
    else
        echo "Status connect Filed" >> $LOG1
        exit 1
else
    echo "Connect Database Failed" >> $LOG1
    exit 1
fi
}


##############################################
#              Main Function                 #
############################################## 
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
            echo "Mode stop normal" >> $LOG1
            kill_session
            exit 0
        else
            echo "Mode stop failed" >> $LOG1
            exit 1
        fi

##### check retuen status kill sesion ######
log = /afc/ERGnrpe/logs