#!/bin/bash
#
# Purpose  : The purpose of this script will shutdown all databases listed in the oratab file
#
#            1.) Input parameter no need
#            2.) Kill pending process
#            3.) return status 0 completed.
# Change History:
#
# Version  Date      Who                  What
# -------- --------- -------- ----------------------------------------------------------------------
# 1.0.0    11 MAY 18 nattapon kuntaisong  Initial Release
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
############################################################################################-

NOW=$(date +"%Y%m%d_%H%M%S")
TMP_ACTIVE_SESS_FILE=$TMP/kill_active_session.sql
LOG=$LOG_DIR/check_kill_sesions.log # name the variable to friendly  : SQL_SESIONLOG
LOG1=$LOGS/auto_kill_sesions_$NOW.log # name the variable to friendly : KILL_SESIONLOG
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

result=$?

    if [ $result -eq 0 ];
    then
        count=`cat $TMP_ACTIVE_SESS_FILE |wc -l`
        if [ $count -eq 0 ];
        then
            echo "There is no active session to kill." >> $LOG1
            exit 0
        else
            sqlplus -s "/as sysdba" < $TMP_ACTIVE_SESS_FILE >> $LOG
            altresult=`grep "System altered." $LOG_DIR/check_kill_sesions.log`
            if [ ! -z "$altresult" ];
            then
                echo "$(date +"%Y%m%d%H%M%S") : Success to kill the active session" >> $LOG1
                exit 0
            else
                echo "$(date +"%Y%m%d%H%M%S") : Fail to kill the active session" >> $LOG1
                exit 202
            fi

        fi
    else
        echo "$(date +"%Y%m%d%H%M%S") : Fail to connect the oracle database" >> $LOG1
        exit 201
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
echo "$(date +"%Y%m%d%H%M%S") Node: $Node"; >> $LOG1
echo "$(date +"%Y%m%d%H%M%S") Mode: $Mode"; >> $LOG1

#Check nodehealt of node type 
item="ofs"

    if [ $Node == "$item" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Node complated" >> $LOG1
    else
        echo "Node failed" >> $LOG1
        exit 255
    fi
    
    if [ $Mode == "normal" ]; 
    then
        echo "$(date +"%Y%m%d%H%M%S") : Mode stop normal" >> $LOG1
        kill_session

    else
        echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
        exit 255
    fi
