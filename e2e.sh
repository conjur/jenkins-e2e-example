#!/bin/bash -eu

function main() {
  start_conjur && start_jenkins
  echo "-----"
  load_conjur_policy
  load_conjur_variable_values
  echo "-----"
  generate_host_factory_token
  issue_jenkins_identity
  echo "-----"
  show_output
}

# 'Private' functions

function start_conjur() {
  docker-compose up -d conjur
}

function start_jenkins() {
  docker-compose up -d --build jenkins
}

function load_conjur_policy() {
  echo "Loading Conjur policy"
  echo "-----"
  docker-compose exec conjur \
    conjur policy load --as-group security_admin policy.yml
}

function load_conjur_variable_values() {
  echo "Loading values for secrets"
  echo "-----"
  docker-compose exec conjur \
    conjur variable values add aws/users/jenkins/access_key_id n8p9asdh89p
  docker-compose exec conjur \
    conjur variable values add aws/users/jenkins/secret_access_key 46s31x2x4rsf
}

function generate_host_factory_token() {
  echo "Generating Host Factory token"
  echo "-----"
  docker-compose exec conjur \
    conjur hostfactory tokens create --duration-days 1 jenkins/executors | jq -r '.[0].token' | tee hftoken.txt
}

function issue_jenkins_identity() {
  docker-compose exec jenkins /src/identify.sh
}

function show_output() {
  echo "Jenkins web URL: http://localhost:8080"
  echo "Jenkins 'admin' password: $(cat jenkins_home/secrets/initialAdminPassword)"
  echo "-----"
  echo "Conjur web UI: https://localhost/ui"
  echo "Conjur 'admin' password: secret"
  echo "Conjur Host Factory token: $(cat hftoken.txt)"
}

main
