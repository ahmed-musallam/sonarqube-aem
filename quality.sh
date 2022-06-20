#!/usr/bin/env bash

# add curl dependency
apk add --no-cache --virtual quality-dependencies curl;

#########
# Creates Sonar Qube Custom Quality Gate.
#########

#set -x

# print in blue color
info () {
  printf "\e[1;34m[quality.sh]:: %s ::\e[0m\n" "$*"
}
# print in red color
error () {
  printf "\e[1;31m[quality.sh]:: %s ::\e[0m\n" "$*"
}

# wait here until sonar is up. sleep 5 seconds between checks.
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

#######
## Quality Gates
#######

# create quality gate
create_gate () {
  post localhost:9000/api/qualitygates/create "$@"
}

# set gate as default
set_as_default_gate () {
  post localhost:9000/api/qualitygates/set_as_default "$@"
}

# create gate condition
create_condition () {
  post localhost:9000/api/qualitygates/create_condition "$@"
}

# by default, the newly created gate ID will be 2; Since Sonar Way gate is 1.
gate_id=2
gate_name=aem-gate

info "Creating Quality Gate: aem-gate"
create_gate -d name=$gate_name

info "Setting aem-gate as the default Quality Gate."
set_as_default_gate -d name=$gate_name

info "Creating Condition: Code Coverage - 75% required"
create_condition \
  -d metric=coverage \
  -d gateName=$gate_name \
  -d error=75 \
  -d op=LT

info "Creating Condition: Code Smells - A required"
create_condition \
  -d metric=code_smells \
  -d gateName=$gate_name \
  -d error=1 \
  -d op=GT

info "Creating Condition: Maintainability Rating - A required"
create_condition \
  -d metric=sqale_rating \
  -d gateName=$gate_name \
  -d error=1 \
  -d op=GT

info "Creating Condition: Reliability Rating - A required"
create_condition \
  -d metric=reliability_rating \
  -d gateName=$gate_name \
  -d error=1 \
  -d op=GT

info "Creating Condition: Security Rating - A required"
create_condition \
  -d metric=security_rating \
  -d gateName=$gate_name \
  -d error=1 \
  -d op=GT

info "Quality Gate Creation Done!"

#######
## Quality Profiles
#######

create_profile () {
  post localhost:9000/api/qualityprofiles/create "$@"
}

change_profile_parent () {
  post localhost:9000/api/qualityprofiles/change_parent "$@"

}

activate_rules () {
  post localhost:9000/api/qualityprofiles/activate_rules "$@"
}

set_default () {
  post localhost:9000/api/qualityprofiles/set_default "$@"
}

get_aem_profile_id () {
  OUT="$(curl  -X POST --user admin:admin -s /dev/null localhost:9000/api/qualityprofiles/search -d qualityProfile=aem-way-java 2>/dev/null)"
  pat='.*"key":"([^"]+)",.*'
  [[ "$OUT" =~ $pat ]]
  echo "${BASH_REMATCH[1]}"
}



#info "Create AEM Profile - Java"
create_profile \
  -d language=java \
  -d name=aem-way-java


info "Make AEM profile Inherit Sonar way"
change_profile_parent \
  -d language=java \
  -d parentQualityProfile="Sonar way" \
  -d qualityProfile="aem-way-java"

info "setting aem-way-java as default"
set_default \
  -d language=java \
  -d qualityProfile="aem-way-java"

PROFILE_KEY=$(get_aem_profile_id)
info "Activating AEM rules"
activate_rules \
  -d repositories="AEM Rules,Common HTL," \
  -d targetKey=$PROFILE_KEY

# clean up curl dependency
apk del --purge quality-dependencies;

info "Quality Profile Creation done!"