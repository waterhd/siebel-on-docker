# Die function
die() { printf "ERROR: $1\n" "${@:2}" >&2; exit 1; }

# Random alphanumeric string
randomString() { tr -cd '[:alnum:]' </dev/urandom | head -c${1:-13}; }
