#!/usr/bin/env bash

#########
# Creates Sonar Qube Custom Quality Gate.
#########

#set -x

# print in blue color
info () {
  printf "\e[1;34m[quality-gates.sh]:: %s ::\e[0m\n" "$*"
}
# print in red color
error () {
  printf "\e[1;31m[quality-gates.sh]:: %s ::\e[0m\n" "$*"
}

# wait here untill sonar is up. sleep 5 seconds between checks.
while [[ "$(curl -s localhost:9000/api/system/status)" != *'"status":"UP"'* ]]; do 
  info "Waiting for Sonar to be ready.."
  sleep 5;
done

info "Sonar is UP! Configuring Quality Gates..."

# default curl options
curl_opts=(
    -X POST 
    --user admin:admin
    -s
    -o /dev/null
    -w '%{http_code}'
)

# Send a post request
post () {
  STATUS=$(curl "${curl_opts[@]}" "$@")
  # some APIs like set_as_default return a 204 for success ops
  if [ $STATUS -eq 200 ] || [ $STATUS -eq 204 ]; then
    info "==> Success!"
  else
    error "==> Failed."
  fi
}

# create quality gate
create () {
  post localhost:9000/api/qualitygates/create "$@"
}

# set gate as default
set_as_default () {
  post localhost:9000/api/qualitygates/set_as_default "$@"
}

# create gate condition
create_condition () {
  post localhost:9000/api/qualitygates/create_condition "$@"
}

# by default, the newly created gate ID will be 2; Since Sonar Way gate is 1.
gate_id=2

info "Creating Quality Gate: aem-gate"
create -d name=aem-gate

info "Setting aem-gate as the default Quality Gate."
set_as_default -d id=$gate_id

info "Creating Condition: Code Coverage - 75% required"
create_condition \
  -d metric=coverage \
  -d gateId=$gate_id \
  -d error=75 \
  -d op=LT

info "Creating Condition: Code Smells - A required"
create_condition \
  -d metric=code_smells \
  -d gateId=$gate_id \
  -d error=1 \
  -d op=GT

info "Creating Condition: Maintainability Rating - A required"
create_condition \
  -d metric=sqale_rating \
  -d gateId=$gate_id \
  -d error=1 
  -d op=GT

info "Creating Condition: Reliability Rating - A required"
create_condition \
  -d metric=reliability_rating \
  -d gateId=$gate_id \
  -d error=1 \
  -d op=GT

info "Creating Condition: Security Rating - A required"
create_condition \
  -d metric=security_rating \
  -d gateId=$gate_id \
  -d error=1 \
  -d op=GT

info "Quality Gate Creation Done!"