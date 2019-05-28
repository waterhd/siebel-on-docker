# DATABASE SCRIPT

# Following only if DB HOST and SERVICE are defined
if [[ $DB_HOST && $DB_SERVICE ]]; then
  log 'Configuring Oracle database client'

  # Set TNS entry
  set-default DB_TNS_ENTRY "$DB_TNS_TEMPLATE" $DB_HOST $DB_PORT $DB_SERVICE

  # Update tnsnames.ora
  set-key $TNS_ADMIN/tnsnames.ora SIEBELDB "$DB_TNS_ENTRY"

  # Wait for database?
  if ((DB_WAIT)); then
    wait-for $DB_HOST:$DB_PORT ${DB_WAIT_TIMEOUT:-$WAIT_TIMEOUT} || die 'Database unavailable'
  fi

  # Install database schema?
  if ((DB_INSTALL)); then
    /siebel/install/db_install.sh
  fi
fi

# Set temp dir
export TMPDIR=/dev/shm

# Siebel gateway connection explicitly defined?
if [[ ! $SIEBEL_GATEWAY ]]; then

  # Check if Gateway hostname is set, if not, use full hostname
  set-default GATEWAY_HOST "$(hostname -f)"

  # Set Siebel Gateway connection string
  set-default SIEBEL_GATEWAY "$GATEWAY_HOST:8990"
fi
