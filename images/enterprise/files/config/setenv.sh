#!/bin/sh
#
# ENVARS for Tomcat and TDS environment
#
echo "Inside setenv.sh"

#PRGDIR="`dirname "$0"`"
#JRE_HOME="$PRGDIR/./../../jre"
#CLASSPATH="$PRGDIR/./../../../DB2_JAR"

# CATALINA_HOME and JRE_HOME now require explicit setting!
echo "Using CATALINA_HOME: $CATALINA_HOME and JRE_HOME: $JRE_HOME"

# Change to Tomcat home directory
cd $CATALINA_HOME

# Set alternative key and trust stores using environment variables
# KEYSTORE and TRUSTSTORE or Docker secrets keystore and truststore.

# If neither are set, default location in /siebel/config is used
# Symbolic links are created/updated at default location (siebelcerts)

# Recreate symbolic link for keystore, if needed
if [ -f "${KEYSTORE:="/run/secrets/keystore"}" ]; then
  ln -sfv "$KEYSTORE" siebelcerts/keystore.jks
fi

# Recreate symbolic link for truststore, if needed
if [ -f "${TRUSTSTORE:="/run/secrets/truststore"}" ]; then
  ln -sfv "$TRUSTSTORE" siebelcerts/truststore.jks
fi

# If set, add JVM Route to Tomcat startup options
if [ -n "$JVM_ROUTE" ]; then
  CATALINA_OPTS="$CATALINA_OPTS -DjvmRoute=$JVM_ROUTE"
fi

if [ -n "$JAVAX_NET_DEBUG" ]; then
  CATALINA_OPTS="$CATALINA_OPTS -Djavax.net.debug=$JAVAX_NET_DEBUG"
fi

if [ -n "$GATEWAY_HOST" ]; then
  CATALINA_OPTS="$CATALINA_OPTS -Dsiebel.gateway.host=$GATEWAY_HOST"
fi

# Add location of keystore and truststore
CATALINA_OPTS="$CATALINA_OPTS
 -Djavax.net.ssl.keyStore=siebelcerts/keystore.jks
 -Djavax.net.ssl.trustStore=siebelcerts/truststore.jks
 -Djavax.net.ssl.keyStorePassword=\"${KEYSTORE_PASSWORD:-changeit}\"
 -Djavax.net.ssl.trustStorePassword=\"${TRUSTSTORE_PASSWORD:-changeit}\""

# Switch to root due to issue with log file naming
cd /
