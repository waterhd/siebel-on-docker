#!/bin/bash

# Require variables in order to continue
require-var DB_TABLEOWNER DB_TABLEOWNER_PASSWORD

# Change to siebsrvr directory
cd /siebel/ses/siebsrvr

# Source dbenv.sh
. dbenv.sh

# Change to bin directory
cd bin

# Alternative odbc.ini location
export ODBCINI=/siebel/install/odbc.ini

# Get table count
tc=$(./odbcsql /s SiebelInstall_DSN /u $DB_TABLEOWNER /p $DB_TABLEOWNER_PASSWORD /h /siebel/install/tablecount.sql) ||
  die 'Could not connect to database'

# If any tables are found, quit
if ((tc)); then log 'Siebel schema already installed!'; exit; fi

# Database schema is empty, continue with installation
require-var DB_USERNAME DB_PASSWORD DB_INDEX_TABLESPACE DB_DATA_TABLESPACE SIEBEL_LANGUAGE

# Install database with primary language
log 'Installing database for primary language: %s' $SIEBEL_LANGUAGE

# Write file
cat >master_install.ucf <<EOF

[Upgrade]
Default Entry = TRUE
Username = $DB_USERNAME
Key Value = $(./encryptstring $DB_PASSWORD)
Key Value 2 = $(./encryptstring $DB_TABLEOWNER_PASSWORD)
ODBC Data Source = SiebelInstall_DSN
Data Source = SiebelInstall_DSN
Table Owner = $DB_TABLEOWNER
Siebel Root = /siebel/ses/siebsrvr
Process Name = install
Language = ${SIEBEL_LANGUAGE^^}
Index Space = $DB_INDEX_TABLESPACE
Table Space = $DB_DATA_TABLESPACE
16K Table Space = \$16KTableSpace
32K Table Space = \$32KTableSpace
Repository Name = Siebel Repository
Repository File Name = /siebel/ses/dbsrvr/common/mstrep.dat
Seed File Name = /siebel/ses/dbsrvr/${SIEBEL_LANGUAGE^^}/seed.dat
Language Specific Seed File Name = /siebel/ses/dbsrvr/${SIEBEL_LANGUAGE^^}/seed_locale.dat
Database Platform = oracle
Database Server = \$DatabaseServer
Schema Qualifier = $DB_TABLEOWNER
Database Owner = $DB_TABLEOWNER
Unicode Flag = Y
Grantee = SSE_ROLE
Dbsrvr Root = /siebel/ses/dbsrvr
Oracle Parallel Index = N
Keep All UpgWiz Files = 1
Database Schema Process = 1
Run Unattended = 1
Orchestrator Mode = 1
Resource Language = ${SIEBEL_LANGUAGE^^}
Siebel Log Directory = /siebel/log/install/output
Siebel Log Events = 3
License Key = \$LicenseKey
Master File Name = master_install.ucf

[Upgrade 1]
File Name = /siebel/ses/dbsrvr/oracle/driver_install.ucf
Is Archived = 0
Title = install
EOF

# Generate SQL files
./sqlgen \
  /M master_install.ucf \
  /X /siebel/ses/dbsrvr/oracle/upgfile.xml \
  /G /siebel/ses/dbsrvr/${SIEBEL_LANGUAGE^^}/upglocale.${SIEBEL_LANGUAGE} \
  /V /siebel/ses/dbsrvr/common/versions.txt || die 'Failed to generate install SQL files'

# Install database
./srvrupgwiz /m master_install.ucf || die 'Failed to install database, check log files for error messages'

# Activate license key
./odbcsql /s SiebelInstall_DSN /u $DB_TABLEOWNER /p $DB_TABLEOWNER_PASSWORD \
  /h /siebel/install/lickey.sql "$LICENSE_KEY_ACTIVATE" || die 'Failed to activate license key(s)'

# DONE
log 'Completed database schema install'
