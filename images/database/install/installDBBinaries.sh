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
# Scripts modified in April 2019 by dennis.waterham@oracle.com

export EDITION=$1

# Exit immediately if any command exits non-zero
set -eo pipefail

# Die function
die() { printf "ERROR: $1\n" "${@:2}" >&2; exit 1; }

# Check for edition
[[ $EDITION ]] || die "No edition provided. Please specify the correct edition!"

# Check for valid editions
[[ $EDITION = 'EE' || $EDITION = 'SE2' ]] || die "Edition %s is not a valid edition!" $EDITION

# Check whether ORACLE_BASE is set
[[ $ORACLE_BASE ]] || die "Oracle Base has not been set. Please provide value using environment variable ORACLE_BASE!"

# Check whether ORACLE_HOME is set
[[ $ORACLE_HOME ]] || die "Oracle Home has not been set. Please provide value using environment variable ORACLE_HOME!"

# Change to install directory
cd $INSTALL_DIR

# Substitute database install response file
envsubst < db_inst.rsp.tmpl | tee db_inst.rsp

# Unzip installers
unzip $INSTALL_FILE_1
unzip $INSTALL_FILE_2

# Remove installers
rm -v $INSTALL_FILE_1 $INSTALL_FILE_2

# Install Oracle DB
$INSTALL_DIR/database/runInstaller -silent -force -waitforcompletion -responsefile $INSTALL_DIR/db_inst.rsp -ignoresysprereqs -ignoreprereq

# Move to home directory
cd $ORACLE_HOME

# Remove not needed components and unnecessary files (such as APEX, ORDS, Sql Developer, etc.)
rm -rf apex ords sqldeveloper ucp dmu suptools network/tools/help assistants/dbua lib/*.zip inventory/backup install/pilot

# Remove installer files
rm -rf /tmp/* $INSTALL_DIR/database

# Move to home directory
cd $HOME

# If needed, install Perl
$ORACLE_HOME/perl/bin/perl -v || . $INSTALL_DIR/installPerl.sh
