#!/bin/bash -e

# Configure database client and set Siebel server specific environment variables
. config.sh

# Run command instead of this script (if supplied)
[[ $1 ]] && exec /bin/bash -c "$@"

# Run stop script on exit
trap '/siebel/stop_server.sh' INT TERM KILL QUIT EXIT

# Forward Tomcat logs to STDOUT of current process
export CATALINA_OUT=/proc/$$/fd/1

# Start Tomcat
$CATALINA_HOME/bin/startup.sh

# Check for Siebel server service file
if [[ -f sys/svc.siebsrvr.$SIEBEL_ENTERPRISE:$SIEBEL_SERVER ]]; then
  # File found, start Siebel server
  log 'Starting Siebel server %s' $SIEBEL_SERVER
  bin/start_server -r "$SIEBEL_ROOT" -e $SIEBEL_ENTERPRISE $SIEBEL_SERVER

# Not found? Run deployment script, if provided
elif [[ -x $DEPLOY_SCRIPT ]]; then
  $DEPLOY_SCRIPT
fi

# Wait command will wait for OS signal
while :; do tail -f /dev/null & wait $!; done
