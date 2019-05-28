ARG UPDATE

FROM siebel/enterprise:${UPDATE}

# Siebel server specific environment variables
ENV GATEWAY_WAIT=true \
    LD_LIBRARY_PATH=/siebel/ses/siebsrvr/lib:/siebel/ses/siebsrvr/mw/lib \
    MWCORE_PRIVATE_DATA=/siebel/ses/siebsrvr/mw/.mw/core_data \
    MWHOME=/siebel/ses/siebsrvr/mw \
    MWOS=linux \
    MWNO_SIGNAL_CATCHING=TRUE \
    MWREGISTRY=/siebel/ses/siebsrvr/mw/system/registry.bin \
    MWSTG_WAITFOROPEN=1 \
    MWSTG_WAITOPEN_TIMEOUT=100 \
    MWUSER_DIRECTORY=/siebel/ses/siebsrvr/mw/.mw \
    ODBCINI=/siebel/ses/siebsrvr/sys/.odbc.ini \
    PATH=$PATH:/siebel:/siebel/ses/siebsrvr/bin:/siebel/ses/siebsrvr/mw/bin \
    SIEBEL_HOME=/siebel/ses/siebsrvr \
    SIEBEL_LIB_DIR=/siebel/ses/siebsrvr/lib \
    SIEBEL_LOG_EVENTS=3 \
    SIEBEL_ROOT=/siebel/ses/siebsrvr \
    SIEBEL_SERVICE=siebsrvr

# Copy config files
COPY --chown=siebel files ./

# Set start script as entrypoint
ENTRYPOINT /siebel/start_server.sh

# Change to Siebel root directory
WORKDIR $SIEBEL_ROOT

# Move data and log files to single location, for use with Docker volumes
# (so data can be persisted when containers are recreated)
RUN /siebel/persist.sh

# Define persistent volume
VOLUME /siebel/config /siebel/log /siebel/fs
