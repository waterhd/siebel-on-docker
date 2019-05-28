#!/bin/bash -e

# Create some needed directories
mkdir -pv /siebel/config /siebel/log /siebel/fs /siebel/log/enterprises

# Make sure files exist
touch metafile srvrmgr.out

# Create start scripts from template
# (Needed in case containers are restarted against an existing server volume)
sed -e "s+^#\(SIEBEL_SERVER_ROOT=\)+\1\"${PWD}\"+" admin/siebel_server.tmpl >bin/siebel_server
sed -e "s+%ODBCLANG%+${SIEBEL_LANGUAGE}+" admin/start_server.tmpl >bin/start_server

# Add permissions
chmod ug+x bin/start_server bin/siebel_server

# Redirecting siebenv.sh and siebenv.csh to /dev/null
# (All environment settings are done in Dockerfile or are dynamic and set using env_docker.sh!)
ln -sfv /dev/null siebenv.sh
ln -sfv /dev/null siebenv.csh

# Persist Siebel Server config files
persist /siebel/config \
  metafile \
  admin/srvrdefs.run \
  admin/srvrdefs_sia.run \
  bin/configdb2 \
  bin/options.bin \
  bin/diccache.dat \
  bin/disable_lang.ksh \
  bin/${SIEBEL_LANGUAGE}/omdefs*.run \
  bin/${SIEBEL_LANGUAGE}/siebel.cfg \
  mw/.mw \
  sys \
  $CATALINA_HOME/siebelcerts/truststore.jks \
  $CATALINA_HOME/siebelcerts/keystore.jks \
  $CATALINA_HOME/bin/setenv.sh \
  $CATALINA_HOME/conf/server.xml \
  $CATALINA_HOME/webapps/*.properties

# Persist log files
persist /siebel/log \
  enterprises \
  log=siebsrvr \
  srvrmgr.out \
  $ORACLE_HOME/cfgtoollogs \
  $CATALINA_HOME/logs=tomcat
