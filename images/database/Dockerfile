# LICENSE UPL 1.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 12c Release 1 Enterprise Edition
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) linuxamd64_12102_database_1of2.zip
#     linuxamd64_12102_database_2of2.zip
#     Download Oracle Database 12c Release 1 Enterprise Edition for Linux x64
#     from http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/database:12.1.0.2-ee .
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim as base

# Maintainer
# ----------
MAINTAINER Gerald Venzl <gerald.venzl@oracle.com>

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/12.1.0.2/dbhome_1 \
    INSTALL_DIR=/opt/install

# Use second ENV so that variable get substituted
ENV PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH \
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib \
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# Navigate to install directory
WORKDIR $INSTALL_DIR

# Copy install files
COPY install/* ./

# Do space check and set up prerequisits
RUN find . -maxdepth 1 -name '*.sh' -not -executable -exec chmod -c +x {} + && \
    ./checkSpace.sh 12 && \
    ./setupLinuxEnv.sh

# Switch to Oracle user
USER oracle

# Build arguments
ARG REPO_URL=http://localhost:8000
ARG INSTALL_FILE_1="linuxamd64_12102_database_1of2.zip"
ARG INSTALL_FILE_2="linuxamd64_12102_database_2of2.zip"
ARG EDITION=EE

# Install DB software binaries
RUN curl -fL#O "$REPO_URL/{$INSTALL_FILE_1,$INSTALL_FILE_2}" && \
    ./installDBBinaries.sh $EDITION && \
    rm -rf $INSTALL_DIR/*

# Switch to root user
USER root

# Copy runtime scripts
COPY --chown=oracle:dba base/* $ORACLE_BASE/

# Run scripts as root and delete install dir
RUN find $ORACLE_BASE -maxdepth 1 -name '*.sh' -not -executable -exec chmod -c ug+x {} + && \
    $ORACLE_BASE/oraInventory/orainstRoot.sh && \
    $ORACLE_HOME/root.sh && \
    rm -rf $INSTALL_DIR

# Switch to Oracle user
USER oracle

# Default settings for new databases
ENV DBCA_TEMPLATE_FILE=General_Purpose.dbc \
    ORACLE_EM_CONFIG=DBEXPRESS \
    ORACLE_CHARACTERSET=AL32UTF8 \
    BASH_ENV=$ORACLE_BASE/functions.sh

# Switch to home directory
WORKDIR /home/oracle

# Data volume
VOLUME ["$ORACLE_BASE/oradata"]

# Expose ports
EXPOSE 1521 5500

# Implement healthcheck
HEALTHCHECK --interval=1m --start-period=5m CMD "$ORACLE_BASE/checkDBStatus.sh" >/dev/null || exit 1

# Define default entrypoint to start Oracle Database
ENTRYPOINT $ORACLE_BASE/runOracle.sh
