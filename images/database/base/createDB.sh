#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Creates an Oracle Database based on following parameters:
#              $ORACLE_SID: The Oracle SID and CDB name
#              $ORACLE_PDB: The PDB name
#              $ORACLE_PWD: The Oracle password
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Exit immediately if any command exits non-zero
set -eo pipefail

# Check whether ORACLE_SID is passed on
export ORACLE_SID=${1:-ORCLCDB}

# Check whether ORACLE_PDB is passed on
export ORACLE_PDB=${2:-ORCLPDB1}

# Auto generate ORACLE PWD if not passed on
export ORACLE_PWD=${3:-"$(randomString 13)1"}

echo "ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: $ORACLE_PWD";

[[ -f $ORACLE_HOME/assistants/dbca/templates/$DBCA_TEMPLATE_FILE ]] ||
  die "TEMPLATE FILE DOESN'T EXIST! Please mount template file $DBCA_TEMPLATE_FILE in path $ORACLE_HOME/assistants/dbca/templates!"

# Replace place holders in response file
sed -E '/(^$|^#)/d' $ORACLE_BASE/dbca.rsp.tmpl | envsubst > $ORACLE_BASE/dbca.rsp

# Show response file
tail -vn+1 $ORACLE_BASE/dbca.rsp

# If there is greater than 8 CPUs default back to dbca memory calculations
# dbca will automatically pick 40% of available memory for Oracle DB
# The minimum of 2G is for small environments to guarantee that Oracle has enough memory to function
# However, bigger environment can and should use more of the available memory
# This is due to Github Issue #307
[[ $(nproc) -le 8 ]] || sed -i -e 's|TOTALMEMORY = "2048"||g' $ORACLE_BASE/dbca.rsp

# Create network related config files (sqlnet.ora, tnsnames.ora, listener.ora)
mkdir -pv $ORACLE_HOME/network/admin

echo "NAMES.DIRECTORY_PATH= (TNSNAMES, EZCONNECT, HOSTNAME)" > $ORACLE_HOME/network/admin/sqlnet.ora

# Listener.ora
cat >$ORACLE_HOME/network/admin/listener.ora << EOF
LISTENER =
(DESCRIPTION_LIST =
  (DESCRIPTION =
    (ADDRESS = (PROTOCOL = IPC)(KEY = EXTPROC1))
    (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  )
)

DEDICATED_THROUGH_BROKER_LISTENER=ON
DIAG_ADR_ENABLED = off
EOF

# Run DBCA
if ! dbca -silent -responseFile $ORACLE_BASE/dbca.rsp; then

  tail -vn+1 \
    /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID/$ORACLE_SID.log \
    /opt/oracle/cfgtoollogs/dbca/$ORACLE_SID.log 2>/dev/null

  die "DBCA encountered an error. Please see log files above."

fi

cat >$ORACLE_HOME/network/admin/tnsnames.ora << EOF
$ORACLE_SID=localhost:1521/$ORACLE_SID

$ORACLE_PDB=
(DESCRIPTION =
  (ADDRESS = (PROTOCOL = TCP)(HOST = 0.0.0.0)(PORT = 1521))
  (CONNECT_DATA =
    (SERVER = DEDICATED)
    (SERVICE_NAME = $ORACLE_PDB)
  )
)
EOF

# Show network config files
tail -vn+1 $ORACLE_HOME/network/admin/*.ora

# Remove second control file, make PDB auto open
sqlplus / as sysdba << EOF
ALTER SYSTEM SET control_files='$ORACLE_BASE/oradata/$ORACLE_SID/control01.ctl' scope=spfile;
ALTER PLUGGABLE DATABASE $ORACLE_PDB SAVE STATE;
EXIT
EOF

# Remove temporary response file
rm -v $ORACLE_BASE/dbca.rsp
