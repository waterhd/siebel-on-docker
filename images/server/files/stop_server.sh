#!/bin/bash

if pgrep -f siebsvc &>/dev/null; then
  # Stop Siebel Server
  log 'Stopping Siebel Server...'
  $SIEBEL_ROOT/bin/stop_server ALL
fi

if pgrep -f catalina &>/dev/null; then
  # Stop Tomcat
  log 'Stopping Tomcat...'
  $CATALINA_HOME/bin/shutdown.sh
fi

# Stop any left over tail processes
pkill -9 tail &>/dev/null || true
