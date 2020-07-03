#!/bin/bash

runLego() {
    ./lego \
    --server "https://acme-staging-v02.api.letsencrypt.org/directory" \
    --email "foo@bar.com" \
    --dns.resolvers "ns-01.hyperone-dns.com" \
    --dns "hyperone" \
    --accept-tos \
    --pem \
    --domains "$1" \
    run
}   

checkDomains() { 
    ((TESTS_COMPLETED++))

    if runLego "$1"
    then
    echo "Successfuly got certificate for $1"
    else
    echo "Could not get certificate for $1" >&2
    ((TESTS_FAILED++))
    fi
}

runDomainTests() {
    local TESTS_COMPLETED=0
    local TESTS_FAILED=0
    local BASE_URL="jakub.dwa-skladniki.pl"

    local SINGLE_DOMAIN_INPUT=$BASE_URL
    local WILDCARD_INPUT="*.wildcard.$BASE_URL"

    checkDomains "$SINGLE_DOMAIN_INPUT"
    checkDomains "$WILDCARD_INPUT"

    echo "Getting certificates finished. Failed $TESTS_FAILED, total $TESTS_COMPLETED."
    if [[ "$TESTS_FAILED" -ne 0 ]]
    then
    exit 1
    fi
}

runDomainTests
