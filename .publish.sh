#!/bin/sh
set -e
: ${PUBLISHURI:?Must be given}

curl -s \
    --header "Content-Type: application/json" \
    --data "{\"build_parameters\": {\"release_tag\": \"$TRAVIS_TAG\"}}" \
    --request POST $PUBLISHURI > /dev/null
