#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# Since: July, 2017
# Author: gerald.venzl@oracle.com
# Description: Runs user shell and SQL scripts
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Exit immediately if any command exits non-zero
set -eo pipefail

# Set variables
script_dir="$1"

# Check whether parameter has been passed on
[[ $script_dir ]] || die "No script directory provided. Scripts will not be run."

# Execute custom provided files (only if directory exists and has files in it)
if [[ -d $script_dir ]] && [[ $(ls -A "$script_dir") ]]; then

  echo "Executing user defined scripts..."

  for script in $script_dir/*; do
    case "$script" in

      # Shell script
      *.sh)  echo "$0: running $script..."
             . "$f";;

      # SQL file
      *.sql) echo "$0: running $script..."
             $ORACLE_HOME/bin/sqlplus -s "/ as sysdba" @"$script";;

      # Other, ignore
      *)     echo "$0: ignoring $script..."
    esac

    echo
  done

  echo "DONE: Executing user defined scripts."
fi
