#!/bin/bash

if pgrep -f siebsvc &>/dev/null; then
  # Stop Gateway Server
  log 'Stopping Siebel Gateway Server...'
  $SIEBEL_ROOT/bin/stop_ns
fi

if pgrep -f catalina &>/dev/null; then
  # Stop Tomcat
  log 'Stopping Tomcat...'
  $CATALINA_HOME/bin/shutdown.sh
fi

# Stop any left over tail processes
pkill -9 tail &>/dev/null || true
