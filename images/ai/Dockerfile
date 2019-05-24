FROM java/serverjre:8

LABEL maintainer="Dennis Waterham <dennis.waterham@oracle.com>"

# Install required packages
RUN yum -y install ksh tcsh gettext which unzip hostname make \
 && yum -q clean all \
 && rm -rf /var/cache/yum

# Add Siebel user with /siebel as home directory
RUN useradd -mlU -u 54330 -d /siebel siebel

# Switch to Siebel user
USER siebel

# Change to /siebel
WORKDIR /siebel

# Copy install files
COPY --chown=siebel install ./

## SIEBEL INSTALL BUILD ARGUMENTS

# Primary language (default: English)
ARG PRIMARY_LANGUAGE=enu

# Additional languages (using colons or comma's as separators), e.g.: EXTRA_LANGUAGES=fin:sve
ARG EXTRA_LANGUAGES

# Siebel update to install
ARG UPDATE

# Default settings and install locations
ENV true=1 false=0 \
    BASH_ENV=/siebel/functions.sh \
    CATALINA_HOME=/siebel/sai/applicationcontainer \
    ENCRYPT_JAR=/siebel/sai/inventory/Scripts/ext/jlib/EncryptString.jar \
    JRE_HOME=$JAVA_HOME/jre \
    LANG=en_US.UTF-8 \
    ORACLE_HOME=/siebel/sai \
    PATH=$PATH:/usr/java/latest/bin \
    RESOLV_MULTI=off \
    SIEBEL_LANGUAGE=$PRIMARY_LANGUAGE \
    WAIT_HOSTS_TIMEOUT=300 \
    WAIT_SLEEP_INTERVAL=5

# Software repository base URL
ARG REPO_URL=http://localhost:8000

# Install Siebel
RUN ./install.sh $REPO_URL "17.0.0.0" $SIEBEL_LANGUAGE $EXTRA_LANGUAGES && \
    ./install.sh $REPO_URL "$UPDATE.0.0.update" $SIEBEL_LANGUAGE $EXTRA_LANGUAGES && \
    cd "$CATALINA_HOME" && \
    rm -rfv bin/*.exe bin/*.bat bin/*.dll bin/*.tar.gz logs/* *.log webapps/siebel.war webapps/example webapps/docs && \
    cd "$ORACLE_HOME" && \
    rm -rf ps_backup inventory/backup /tmp/*

# CATALINA_OPTS
# =============
# The JVM will apply the Docker --cpuset-cpus limit as the number of CPUs the JVM sees in the docker container.
# If -XX:ParallelGCThreads or -XX:CICompilerCount are specified and a --cpuset-cpus limit is specified the JVM
# will use the -XX:ParallelGCThreads and -XX:CICompilerCount values. See JDK-6515172 for details.

# To configure the maximum Java heap size to match Docker memory limits without setting a maximum Java heap
# via -Xmx use two JVM command line options:
# -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap
# When these two JVM command line options are used, and -Xmx is not specified, the JVM will look at the Linux
# cgroup configuration, which is what Docker containers use for setting memory limits,
# to transparently size a maximum Java heap size.
# See JDK-8170888 for details.

ENV JAVA_OPTS -server -XX:+UnlockExperimentalVMOptions -XX:+UseCGroupMemoryLimitForHeap -Djava.net.preferIPv4Stack=true -Djava.awt.headless=true -Dfile.encoding=UTF-8

# Switch to Siebel user
USER siebel

# Copy additional files, scripts, etc.
COPY --chown=siebel files ./

# Change to CATALINA Home
WORKDIR $CATALINA_HOME

# Move data and log files to single location, for use with Docker volumes
# (so data can be persisted when containers are recreated)
RUN /siebel/persist.sh

# Expose HTTPS port
EXPOSE 8443

# Declare persistent volume
VOLUME /siebel/config /siebel/log /siebel/custom

# Set entrypoint
ENTRYPOINT bin/catalina.sh run
