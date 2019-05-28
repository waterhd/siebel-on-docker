ARG ORACLE_VERSION=12.1.0.2

FROM oracle/instantclient-32:${ORACLE_VERSION}

LABEL maintainer="Dennis Waterham <dennis.waterham@oracle.com>"

# Set bash shell
SHELL ["/bin/bash", "-uec"]

# Install required packages
# (use rpm command to install same version as 64 bit, prevents multilib issues)
RUN yum -y install ksh tcsh gettext which unzip hostname make libX11.i686 libXext.i686 libXt.i686 jq \
 && rpm -q glibc libstdc++ libgcc compat-libstdc++-33 | sed 's/x86_64/i686/' | xargs yum -y install \
 && yum -q clean all \
 && rm -rf /var/cache/yum

# Add Siebel user with /siebel as home directory
RUN useradd -mlU -u 54330 -d /siebel siebel

# Switch to Siebel user
USER siebel

# Switch to /siebel
WORKDIR /siebel

# Copy files recursively (creates necessary directory structure)
COPY --chown=siebel install ./

## SIEBEL INSTALL BUILD ARGUMENTS
# Primary language
ARG PRIMARY_LANGUAGE=enu
# Additional languages (using colons or comma's as separators), e.g.: EXTRA_LANGUAGES=fin:sve
ARG EXTRA_LANGUAGES=
# Siebel update to install
ARG UPDATE=19.3
# With or without database configuration utilities. Without this, database cannot be populated automatically.
ARG WITH_DBSRVR=true

# Default settings and install locations
ENV true=1 false=0 \
    BASH_ENV=/siebel/functions.sh \
    CATALINA_HOME=/siebel/ses/applicationcontainer \
    ENCRYPT_JAR=/siebel/ses/inventory/Scripts/ext/jlib/EncryptString.jar \
    EXTRA_LANGUAGES=$EXTRA_LANGUAGES \
    JRE_HOME=/usr/java/jdk/jre \
    LANG=en_US.UTF-8 \
    ORACLE_HOME=/siebel/ses \
    RESOLV_MULTI=off \
    SIEBEL_FS=/siebel/fs \
    SIEBEL_LANGUAGE=$PRIMARY_LANGUAGE \
    SIEBEL_OSD_MAXLIMITS=1 \
    SIEBEL_SHM_DIR=/dev/shm \
    SIEBEL_UNIXUNICODE_DB=ORACLE \
    TNS_ADMIN=/siebel/config \
    WAIT_TIMEOUT=1800 \
    WITH_DBSRVR=$WITH_DBSRVR

# Software repository base URL
ARG REPO_URL=http://localhost:8000

# Install Siebel
RUN ./install.sh $REPO_URL "17.0.0.0" $SIEBEL_LANGUAGE $EXTRA_LANGUAGES && \
    ./install.sh $REPO_URL "$UPDATE.0.0.update" $SIEBEL_LANGUAGE $EXTRA_LANGUAGES && \
    cd "$CATALINA_HOME" && \
    rm -rfv bin/*.exe bin/*.bat bin/*.dll bin/*.tar.gz logs/* *.log webapps/siebel.war webapps/example webapps/docs && \
    cd "$ORACLE_HOME" && \
    rm -rf ps_backup inventory/backup jre /tmp/* siebsrvr/mw/.mw/core_data/* dbsrvr/db2udb dbsrvr/db2390 dbsrvr/mstrep_locale.dat && \
    ln -sfv $JRE_HOME .

# Set defaults
ENV DB_PORT=1521 \
    DB_TABLEOWNER=SIEBEL \
    SADMIN_USERNAME=SADMIN \
    REGISTRY_USERNAME=SADMIN \
    REGISTRY_PORT=2320 \
    ENTERPRISE=SIEBEL

# DB client TNS template
ENV DB_TNS_TEMPLATE (DESCRIPTION=(ADDRESS_LIST=(ADDRESS=(PROTOCOL=TCP)(HOST=%s)(PORT=%d)))(CONNECT_DATA=(SERVICE_NAME=%s)))

# Tomcat JVM options
ENV JAVA_OPTS -server -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Dfile.encoding=UTF-8

# Copy additional files, scripts, etc.
COPY --chown=siebel files ./

# Remove log4j2 config file, all logs will go to console
RUN rm -v $CATALINA_HOME/webapps/siebel/WEB-INF/log4j2-siebel.xml
