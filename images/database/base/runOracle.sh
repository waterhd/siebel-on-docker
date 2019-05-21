#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Runs the Oracle Database inside the container
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Exit immediately if any command exits non-zero
set -eo pipefail

########### Move DB files ############
function moveFiles {

  # Create directory
  [[ -d $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID ]] || mkdir -pv $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID

  # Move files
  mv $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora \
     $ORACLE_HOME/dbs/orapw$ORACLE_SID \
     $ORACLE_HOME/network/admin/sqlnet.ora \
     $ORACLE_HOME/network/admin/listener.ora \
     $ORACLE_HOME/network/admin/tnsnames.ora \
     $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/

  # oracle user does not have permissions in /etc, hence cp and not mv
  cp /etc/oratab $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/

  symLinkFiles;
}

########### Symbolic link DB files ############
function symLinkFiles {

  [[ -L $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora ]] ||
    ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/spfile$ORACLE_SID.ora $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora

  [[ -L $ORACLE_HOME/dbs/orapw$ORACLE_SID ]] ||
    ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/orapw$ORACLE_SID $ORACLE_HOME/dbs/orapw$ORACLE_SID

  [[ -L $ORACLE_HOME/network/admin/sqlnet.ora ]] ||
    ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/sqlnet.ora $ORACLE_HOME/network/admin/sqlnet.ora

  [[ -L $ORACLE_HOME/network/admin/listener.ora ]] ||
    ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/listener.ora $ORACLE_HOME/network/admin/listener.ora

  [[ -L $ORACLE_HOME/network/admin/tnsnames.ora ]] ||
    ln -s $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/tnsnames.ora $ORACLE_HOME/network/admin/tnsnames.ora

  # oracle user does not have permissions in /etc, hence cp and not ln
  cp $ORACLE_BASE/oradata/dbconfig/$ORACLE_SID/oratab /etc/oratab
}

########### SIGINT handler ############
function _term() {
  printf 'Stopping container.\n%s received, shutting down database!\n' $1

  # Stop database
  if [[ $1 = 'SIGKILL' ]]; then
    # Kill the database
    sqlplus / as sysdba <<< "SHUTDOWN ABORT"
  else
    # Shut down cleanly
    sqlplus / as sysdba <<< "SHUTDOWN IMMEDIATE"
  fi

  # Stop listener
  lsnrctl stop

  # Kill any tail processes
  pkill -9 tail &>/dev/null
}

###################################
############# MAIN ################
###################################

# Check whether container has enough memory
container_mem=$(cat /sys/fs/cgroup/memory/memory.limit_in_bytes)

# Check for
[[ ${container_mem} -lt 2147483648 ]] && die "The container doesn't have enough memory allocated. At least 2GB is required."

# Check that hostname doesn't container any "_" (Github issue #711)
[[ ${HOSTNAME} =~ _ ]] && die "Hostname is set to $HOSTNAME. Underscores are not allowed!"

# Shutdown database when receiving a signal
trap "_term SIGINT" SIGINT
trap "_term SIGTERM" SIGTERM
trap "_term SIGKILL" SIGKILL

# Validate Oracle SID
if [[ ! $ORACLE_SID ]]; then

  # Set default value
  export ORACLE_SID=ORCLCDB

else

  # Make ORACLE_SID upper case (Github issue # 984)
  export ORACLE_SID=${ORACLE_SID^^}

  # Check whether SID is no longer than 12 bytes (Github issue #246: Cannot start OracleDB image)
  [[ "${#ORACLE_SID}" -gt 12 ]] && die "The ORACLE_SID must only be up to 12 characters long."

  # Check whether SID is alphanumeric (Github issue #246: Cannot start OracleDB image)
  [[ "$ORACLE_SID" =~ [^a-zA-Z0-9] ]] && die "The ORACLE_SID must be alphanumeric."

fi;

# Default for ORACLE PDB
export ORACLE_PDB=${ORACLE_PDB:-ORCLPDB1}

# Make ORACLE_PDB upper case (github issue # 984)
export ORACLE_PDB=${ORACLE_PDB^^}

# Check whether database already exists
if [[ -d $ORACLE_BASE/oradata/$ORACLE_SID ]]; then
  symLinkFiles;

  # Make sure audit file destination exists
  [[ -d $ORACLE_BASE/admin/$ORACLE_SID/adump ]] || mkdir -p $ORACLE_BASE/admin/$ORACLE_SID/adump

  # Start database
  $ORACLE_BASE/startDB.sh

else

  # Remove database config files, if they exist
  rm -fv \
     $ORACLE_HOME/dbs/spfile$ORACLE_SID.ora \
     $ORACLE_HOME/dbs/orapw$ORACLE_SID \
     $ORACLE_HOME/network/admin/sqlnet.ora \
     $ORACLE_HOME/network/admin/listener.ora \
     $ORACLE_HOME/network/admin/tnsnames.ora

  # Create database
  $ORACLE_BASE/createDB.sh $ORACLE_SID $ORACLE_PDB $ORACLE_PWD

  # Move database operational files to oradata
  moveFiles;

  # Execute custom provided setup scripts
  $ORACLE_BASE/runUserScripts.sh $ORACLE_BASE/scripts/setup

  # Start listener
  lsnrctl start

  # Register with listener
  sqlplus / as sysdba <<< "ALTER SYSTEM REGISTER;"

  # Sleep a few seconds
  sleep 5
fi;

# Check whether database is up and running
$ORACLE_BASE/checkDBStatus.sh || die "DATABASE SETUP WAS NOT SUCCESSFUL! Please check output for further info."

# Shutdown database on script exit
trap "_term EXIT" EXIT

cat >&1 <<EOF
###########################
 DATABASE IS READY TO USE!
###########################
EOF

# Execute custom provided startup scripts
$ORACLE_BASE/runUserScripts.sh $ORACLE_BASE/scripts/startup

# Tail on alert log and wait (otherwise container will exit)

echo "The following output is now a tail of the database alert log:"
echo "============================================================="

tail -f $ORACLE_BASE/diag/rdbms/*/*/trace/alert*.log &

# Wait for termination signal
childPID=$!
wait $childPID
