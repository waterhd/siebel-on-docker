#!/bin/bash -e

# Create some needed directories
mkdir -pv /siebel/config /siebel/log /siebel/data

# Copy start_ns script from template
cp admin/start_ns.tmpl bin/start_ns

# Redirecting siebenv.sh and siebenv.csh to /dev/null
# (All environment settings are done in Dockerfile or are dynamic and set using env_docker.sh!)
ln -sfv /dev/null siebenv.sh
ln -sfv /dev/null siebenv.csh

# Create some needed directories
mkdir -pv zookeeper/version-2

# Persist Gateway files
persist /siebel/config \
  bin/gateway.cfg \
  admin \
  sys \
  zookeeper/conf=zk-conf \
  zookeeper/myid=zk-myid \
  $CATALINA_HOME/siebelcerts/truststore.jks \
  $CATALINA_HOME/siebelcerts/keystore.jks \
  $CATALINA_HOME/bin/setenv.sh \
  $CATALINA_HOME/conf/server.xml \
  $CATALINA_HOME/webapps/*.properties \
  $CATALINA_HOME/webapps/bcgInfo.txt

# Persist Gateway data
persist /siebel/data \
  zookeeper/version-2

# Persist log files
persist /siebel/log \
  log=gtwysrvr \
  srvrmgr.out \
  migration.log \
  $ORACLE_HOME/cfgtoollogs \
  $CATALINA_HOME/logs=tomcat \
  $CATALINA_HOME/webapps/siebel/WEB-INF/siebelsecurityadapter.log
