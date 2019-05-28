# Following only if DB HOST and SERVICE are defined
if [[ $DB_HOST && $DB_SERVICE ]]; then
  log 'Configuring Oracle database client'

  # Set TNS entry
  [[ $DB_TNS_ENTRY ]] || set-default DB_TNS_ENTRY "$DB_TNS_TEMPLATE" $DB_HOST $DB_PORT $DB_SERVICE

  # Update tnsnames.ora
  set-key $TNS_ADMIN/tnsnames.ora SIEBELDB "$DB_TNS_ENTRY"

fi

# ADDITIONAL SETTINGS FOR SIEBEL SERVER
log 'Setting additional environment variables...'

# We need Siebel Enterprise name for automatic startup
require-var SIEBEL_ENTERPRISE

# If Siebel server name is not defined, use short host name
set-default SIEBEL_SERVER "$(hostname -s)"

# Set temp directory
set-default TMPDIR /dev/shm

# Siebel gateway connection explicitly defined?
if [[ ! $SIEBEL_GATEWAY ]]; then
  # Check if metafile has contents

  if [[ -s metafile ]]; then
    # Get gateway info from there
    set-default SIEBEL_GATEWAY "$(< metafile)"

  else
    # Check if Gateway FQDN is set
    require-var GATEWAY_HOST

    # Set Siebel Gateway connection string
    set-default SIEBEL_GATEWAY '%s:%d' $GATEWAY_HOST 8990
  fi
fi

# Wait for database?
if ((GATEWAY_WAIT)); then
  # Set default gateway wait time out
  set-default GATEWAY_WAIT_TIMEOUT $WAIT_TIMEOUT

  # Wait for gateway
  wait-for $SIEBEL_GATEWAY $GATEWAY_WAIT_TIMEOUT || die 'Siebel Gateway unavailable'
fi

# Mainwin
$MWHOME/bin/regautobackup -off
