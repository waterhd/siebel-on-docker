#!/bin/bash

# Stop on error
set -eo pipefail

# Change into deploy directory
cd /siebel/deploy

# Wait for deployment port
wait-for localhost:8081

# HTTP call with pause...
cg_http() {
  case "$1" in
    'POST') curl -kf -X POST $auth -d@- -H "Content-Type: application/json" -H "Accept: application/json" "$CG_HOST_URI/$2" && sleep 4;;
    'GET')  curl -sSkf $auth -H "Accept: application/json" "$CG_HOST_URI/$2";;
    *) die "Method not implemented!";;
  esac

  ret=$?
  printf '\n\n'
  return $ret
}

# Get heartbeat
cg_http GET heartbeat

# Get bootstrap information
cg_http GET bootstrapCG

require-var DB_HOST DB_PORT DB_SERVICE SADMIN_USERNAME SADMIN_PASSWORD REGISTRY_PORT

# Default gateway security profile
set-default GW_SECURITY_PROFILE db

# Security jq file
secjq=sec_$GW_SECURITY_PROFILE.jq

# Deploy Gateway Security Profile
log 'Deploying Gateway Security profile'
jq -nf $secjq | cg_http POST GatewaySecurityProfile || die 'Failed to deploy security profile'

# From now on, use basic authentication
auth="-u $SADMIN_USERNAME:$SADMIN_PASSWORD"

# Bootstrap Gateway
log 'Bootstrapping Siebel Gateway'
jq -nf bootstrap.jq | cg_http POST bootstrapCG || die 'Failed to bootstrap Siebel Gateway'

if [[ ! $SIEBEL_ENTERPRISE ]]; then
  log 'Enterprise not set, ending deployment'
  exit 0
fi

# Check for required variables
require-var SIEBEL_FS DB_USERNAME DB_PASSWORD DB_TABLEOWNER

# Create Enterprise Profile
log 'Deploying enterprise profile'
jq -nf ent_profile.jq | cg_http POST profiles/enterprises || die 'Failed to deploy enterprise profile'

# Deploy Enterprise
log 'Deploying Siebel Enterprise'
jq -nf ent_deploy.jq | cg_http POST deployments/enterprises || die 'Failed to deploy enterprise'

# Sleep for 5 minutes
log 'Sleeping for 5 minutes, waiting for enterprise to be deployed!'
sleep 300;

# Check if enterprise is deployed
cg_http GET deployments/enterprises/$SIEBEL_ENTERPRISE | jq -e '.DeploymentInfo.Status == "Deployed"' ||
  die 'Failed to deploy enterprise'

# DEPLOY SERVERS using comma separated list in environment variable DEPLOY_SERVER
for server in ${DEPLOY_SERVER//,/ }; do
  # Get server profile, defaulting to callcenter
  var=PROFILE_$server; profile=${!var:-'callcenter'}

  # Check for server profile
  if ! cg_http GET profiles/servers/$profile; then
    # Not found, deploy it
    log "Deploying server profile $profile"
    jq -nf server_$profile.jq | cg_http POST profiles/servers || die 'Failed to deploy server profile'
  fi

  # Wait for server to be available
  wait-for $server.$DOMAIN:8443

  # Deploy server
  log "Deploying server $server with profile $profile"
  jq --arg hostIP   "$server.$DOMAIN:8443" \
     --arg profile  "$profile" \
     --arg action   "Deploy" \
     --arg name     "$server" \
     --arg descr    "Siebel Server $server" \
     --arg lang     $SIEBEL_LANGUAGE \
     -nf deploy_server.jq | cg_http POST deployments/servers || die 'Failed to deploy server'

  log 'Sleeping for a minute, before continuing deployment'
  sleep 60
done

# DEPLOY AI NODES using comma separated list in environment variable DEPLOY_SWSM
for ai in ${DEPLOY_SWSM//,/ }; do
  # Get name of AI profile, defaulting to callcenter
  var=PROFILE_$ai; profile=${!var:-'callcenter'}

  # Check for server profile
  if ! cg_http GET profiles/swsm/$profile; then
    # Not found, deploy it
    log "Deploying AI profile $profile"
    jq -nf swsm_$profile.json | cg_http POST profiles/swsm || die 'Failed to deploy AI profile'
  fi

  # Wait for AI node to be available
  wait-for $ai.$DOMAIN:8443

  # Deploy server
  log "Deploying AI node $server with profile $profile"
  jq --arg hostIP   "$ai.$DOMAIN:8443" \
     --arg profile  "$profile" \
     --arg action   "Deploy" \
     --arg name     "$ai" \
     --arg descr    "AI $ai" \
     -nf deploy_swsm.jq | cg_http POST deployments/swsm || die 'Failed to deploy AI node'

  log 'Sleeping for a minute, before continuing deployment'
  sleep 60
done

# DONE
log 'Automatic deployment finished!'
