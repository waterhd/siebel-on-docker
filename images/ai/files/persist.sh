#!/bin/bash -e

# Create some needed directories
mkdir -pv /siebel/config /siebel/log /siebel/custom

# Create some files in advance
touch migration.log

# Remove log4j2 configuration
rm -fv webapps/siebel/WEB-INF/log4j2-siebel.xml

# Persist Tomcat files to config directory
persist /siebel/config \
  siebelcerts/truststore.jks \
  siebelcerts/keystore.jks \
  bin/setenv.sh \
  conf/server.xml \
  webapps/*.properties \
  webapps/cgclientstore.dat \
  conf/web.xml

# Persist log files
persist /siebel/log \
  $ORACLE_HOME/cfgtoollogs \
  logs=tomcat \
  migration.log \
  webapps/siebel/WEB-INF/siebelsecurityadapter.log \
  webapps/GatewayServiceFramework.log

# Persist directories for custom static web files
persist /siebel/custom \
  webapps/siebel/files/custom=files \
  webapps/siebel/scripts/siebel/custom=scripts \
  webapps/siebel/images/custom=images
