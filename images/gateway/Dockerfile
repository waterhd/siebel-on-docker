ARG UPDATE

FROM siebel/enterprise:$UPDATE

ENV DB_WAIT=true \
    DB_INSTALL=false \
    LD_LIBRARY_PATH=/siebel/ses/gtwysrvr/lib \
    LOG_FILE=/siebel/ses/gtwysrvr/log/NameSrvr.log \
    ODBCINI=/siebel/ses/gtwysrvr/sys/.odbc.ini \
    PATH=$PATH:/siebel:/siebel/ses/gtwysrvr/bin \
    SIEBEL_HOME=/siebel/ses/gtwysrvr \
    SIEBEL_LIB_DIR=/siebel/ses/gtwysrvr/lib \
    SIEBEL_ROOT=/siebel/ses/gtwysrvr \
    SIEBEL_SERVICE=gtwyns \
    SIEBEL_LOG_EVENTS=3

# Copy scripts
COPY --chown=siebel files ./

# Set start script as entrypoint
ENTRYPOINT /siebel/start_gateway.sh

# Change to Siebel root directory
WORKDIR $SIEBEL_ROOT

# Create database install script and move data and log files to single location, for use with Docker volumes
RUN /siebel/ses/siebsrvr/install_script/install/CreateDbSrvrEnvScript /siebel/ses $SIEBEL_LANGUAGE oracle && \
    /siebel/persist.sh

# Expose TLS port
EXPOSE 8990

# Define volumes
VOLUME /siebel/config /siebel/log /siebel/data
