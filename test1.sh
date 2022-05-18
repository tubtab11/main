export ORACLE_SID=EBMQA01
export ORACLE_BASE=/app/oracle
export ORACLE_HOME=/app/oracle/product/server_ee/19.5.0.0
export PATH=$PATH:$ORACLE_HOME/bin
export ORATAB=/var/opt/oracle/oratab
export TMP=/tmp

export SCRIPT_DIR=$ORACLE_BASE/admin/$ORACLE_SID/scripts/
export LOG_DIR=$ORACLE_BASE/admin/$ORACLE_SID/scripts/logs
export LOGS=/afc/ERGnrpe/logs
############################################################################################-
TMP_ACTIVE_SESS_FILE=$TMP/kill_active_session.sql
NOW=$(date +"%Y%m%d_%H%M%S")
LOG1=$LOGS/auto_$NOW.log
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
           
            exit 0
        else
            echo "$(date +"%Y%m%d%H%M%S") : Mode stop failed" >> $LOG1
            exit 255
        fi
        
#========================
## Function Kill Pending User on Database ##
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

sqlplus -s "/as sysdba" < $TMP_ACTIVE_SESS_FILE >> $LOG1
result=$?

    if [ $result -eq 0 ];
    then
        echo "$(date +"%Y%m%d%H%M%S") : Success to connect the oracle database" >> $LOG1
        exit 0
    else
        echo "$(date +"%Y%m%d%H%M%S") : Fail to connect the oracle database" >> $LOG1
        exit 201
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
        echo "$(date +"%Y%m%d%H%M%S") : SHUTDOWN FORCE" >>$LOG1
        exit 0
        else
        echo "$(date +"%Y%m%d%H%M%S") : SHUTDOWN SMOOTH" >>$LOG1
        exit 0
        fi
