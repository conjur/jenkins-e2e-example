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
  docker-compose up -d jenkins_without_conjur
  docker-compose up -d --build jenkins_with_conjur
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
    conjur variable values add aws/users/jenkins/access_key_id AKIAIOSFODNN7EXAMPLE
  docker-compose exec conjur \
    conjur variable values add aws/users/jenkins/secret_access_key 'wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY'
}

function generate_host_factory_token() {
  echo "Generating Host Factory token"
  echo "-----"
  docker-compose exec conjur \
    conjur hostfactory tokens create --duration-days 1 jenkins/masters | jq -r '.[0].token' | tee hftoken.txt
}

function issue_jenkins_identity() {
  # Copy the public SSL cert out of Conjur master
  docker cp "$(docker-compose ps -q conjur):/opt/conjur/etc/ssl/ca.pem" conjur.pem
  # Copy that cert into the Jenkins master
  docker cp conjur.pem "$(docker-compose ps -q jenkins_with_conjur):/etc/conjur.pem"

  docker-compose exec --user root jenkins_with_conjur /src/identify.sh
}

function show_output() {
  echo "Jenkins without Conjur web URL: http://localhost:8080"
  echo "Jenkins without Conjur 'admin' password: $(cat jenkins_without_conjur/secrets/initialAdminPassword)"
  echo "-----"
  echo "Jenkins with Conjur web URL: http://localhost:8081"
  echo "Jenkins with Conjur 'admin' password: $(cat jenkins_with_conjur/secrets/initialAdminPassword)"
  echo "-----"
  echo "Conjur web UI: https://localhost/ui"
  echo "Conjur 'admin' password: secret"
  echo "Conjur Host Factory token: $(cat hftoken.txt)"
}

main
