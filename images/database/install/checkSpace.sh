#!/bin/bash
# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# Since: January, 2017
# Author: gerald.venzl@oracle.com
# Description: Checks the available space of the system.
#
# DO NOT ALTER OR REMOVE COPYRIGHT NOTICES OR THIS HEADER.
#
# Scripts modified in April 2019 by dennis.waterham@oracle.com

# Exit immediately if any command exits non-zero
set -eo pipefail

# Die function
die() { printf "ERROR: $1\n" "${@:2}" >&2; exit 1; }

required=${1:-12}
available=$(df -PB 1G / | tail -1 | awk '{print $4}')

# Exit if not enough space is available
[[ $available -ge $required ]] ||
  die "Not enough space available in Docker container. At least %dGB is needed, but only %dGB is available." $required $available
