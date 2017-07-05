#!/bin/bash -e

# Fetch secrets with Summon: https://github.com/conjurinc/summon

echo "Fetching AWS secrets"

echo "$(summon-conjur aws/users/jenkins/access_key_id)"

echo "$(summon-conjur aws/users/jenkins/secret_access_key)"
