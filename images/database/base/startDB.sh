#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# Since: November, 2016
# Author: gerald.venzl@oracle.com
# Description: Starts the Listener and Oracle Database.
#              The ORACLE_HOME and the PATH has to be set.
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Check if Oracle Home is set
[[ $ORACLE_HOME ]] || die "ORACLE_HOME is not set. Please set ORACLE_HOME and PATH before invoking this script."

# Start database
sqlplus / as sysdba <<< "STARTUP"

# Start Listener
lsnrctl start

# Force registration with listener
sqlplus / as sysdba <<< "ALTER SYSTEM REGISTER"
