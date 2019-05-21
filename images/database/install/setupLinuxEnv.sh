#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2016 Oracle and/or its affiliates. All rights reserved.
#
# Since: December, 2016
# Author: gerald.venzl@oracle.com
# Description: Sets up the unix environment for DB installation.
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#

# Setup filesystem and oracle user
# Adjust file permissions, go to /opt/oracle as user 'oracle' to proceed with Oracle installation
# ------------------------------------------------------------
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Stop on first error
set -eo pipefail

# Install necessary packages
yum -y install oracle-rdbms-server-12cR1-preinstall tar openssl unzip gettext

# Clean yum cache
yum -q clean all
rm -rf /var/cache/yum/*

# Create directories
mkdir -pv \
  $ORACLE_BASE/scripts/setup \
  $ORACLE_BASE/scripts/startup \
  $ORACLE_BASE/oradata \
  $ORACLE_HOME

# Create symbolic links
ln -sv $ORACLE_BASE/scripts /docker-entrypoint-initdb.d
ln -s $ORACLE_BASE/setPassword.sh /home/oracle/

# Change password
echo oracle:oracle | chpasswd

# Change ownership of Oracle base directory and install directory to oracle user
chown -R oracle:dba $ORACLE_BASE $INSTALL_DIR
