# FUNCTION FILE. TO BE SOURCED, NOT EXECUTED.

# Log a message
log() { printf "[%(%F %T%z)T]: $1\n" -1 "${@:2}"; }

# Log a message and exit
die() { log "ERROR: $1" "${@:2}" >&2; exit 1; }

# Escape a value for use in sed
sed-escape() { printf "$1" | sed -e 's/[\/&]/\\&/g'; }

# Encrypt a string
encrypt() { java -jar $ENCRYPT_JAR "$1"; }

# Require variable(s) or die
require-var() {
  for var; do
    if [[ ${!var} ]]; then
      log 'Environment variable %s set to: %s' $var "${!var}"
    else
      die 'Required environment variable %s not set!' $var
    fi
  done
}

# Set default value for environment variable
set-default() {
  local var=$1; shift
  if [[ ${!var} ]]; then
    log 'Environment variable %s set to: %s' $var "${!var}"
  else
    printf -v $var "$@"
    log 'Setting environment variable %s to default value: %s' $var "${!var}"
    export $var
  fi
}

# Update key in Java property file / INI file
set-key() {
  local file=$1 key=$2 val=$3 esc=$(sed-escape $3)

  # Check if file exists
  if [[ ! -f $file ]]; then log "File %s doesn't exist!" "$file"; return 1; fi

  log 'Setting property %s in file %s to: %s' $key "$file" "$val"

  # Replace using sed
  sed -i --follow-symlinks -e "/^$key[ ]*=/{h;s/\(=[ ]*\).*/\1$esc/};\${x;/^\$/{s//$key=$esc/;H};x}" "$file"

  # Show file if in debug mode
  if ((DEBUG)); then tail -vn+1 "$file"; fi
}

# Populate file(s) from template
file-from-template() {
  local template=$1 file=$2

  # Check if file exists
  if [[ ! -f $template ]]; then log "File $template doesn't exist!"; return 1; fi

  log 'Creating file %s from template %s' "$file" "$template"

  # Populate from template
  envsubst <"$template" >"$file"

  # Show file if in debug mode
  if ((DEBUG)); then tail -vn+1 "$file"; fi
}

# Persist a file or directory
persist() {
  local dir=$(realpath $1) from to par

  while shift && [[ $1 ]]; do
    # Skip unmatched wildcards
    [[ $1 =~ \* ]] && continue

    # Set name of source and target file
    from=${1%=*} to=${1##*/} to=${dir}/${to#*=} par=${to%/*}

    printf "* Persisting directory or file(s) from '%s' to '%s'...\n" "$from" "$to"

    # Create target parent directory, if needed
    [[ -d $par ]] || mkdir -p "$par"

    # If source exists but target doesn't, move source to target
    [[ -e $from && ! -e $to ]] && mv "$from" "$to"

    # Create symbolic link from target
    ln -sf "$to" "$from"
  done
}

wait-for() {
  local host=${1%:*} port=${1#*:} timeout=${2:-30} begin end

  # Set begin and end
  begin=$SECONDS end=$((SECONDS+timeout))

  log 'Waiting for %s:%d for a maximum of %d seconds' $host $port $timeout

  while :; do
	  if { echo >/dev/tcp/$host/$port; } &>/dev/null; then
      log 'Host %s available after %d seconds' $host $((SECONDS - begin))
      return 0
    elif ((SECONDS >= end)); then
      log 'Time out occurred waiting for host %s' $host
      return 1
    else
      echo $SECONDS $end
      sleep 5
    fi
  done
}
