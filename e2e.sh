#!/bin/bash -eu

function main() {
  start_conjur && start_jenkins

  load_conjur_policy
  load_conjur_variable_values
  generate_host_factory_token
}

# 'Private' functions

function start_conjur() {
  docker-compose up -d conjur
}

function start_jenkins() {
  docker-compose up -d jenkins-master
}

function load_conjur_policy() {
  docker-compose exec conjur \
    conjur policy load --as-group security_admin policy.yml
}

function load_conjur_variable_values() {
  docker-compose exec conjur \
    conjur variable values add aws/users/jenkins/access_key_id n8p9asdh89p
  docker-compose exec conjur \
    conjur variable values add aws/users/jenkins/secret_access_key 46s31x2x4rsf
}

function generate_host_factory_token() {
  docker-compose exec conjur \
    conjur hostfactory tokens create --duration-days 1 jenkins/executors | jq -r '.[0].token' | tee hftoken.txt
}

main
