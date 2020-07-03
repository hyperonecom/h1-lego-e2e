#!/bin/bash

runLego() {
    ./lego \
    --server "https://acme-staging-v02.api.letsencrypt.org/directory" \
    --email "foo@bar.com" \
    --dns.resolvers "ns-01.hyperone-dns.com" \
    --dns "hyperone" \
    --accept-tos \
    --domains "$1" \
    run
}

runOpenSSL() {
    local CERT_NAME="${1//\*/_}" # replace "*"" with "_" for wildcards
    openssl verify "/lego/.lego/certificates/$CERT_NAME.crt"
}

checkDomain() { 
    if runLego "$1"
    then
    echo "Successfully got certificate for $1"
    else
    echo "Could not get certificate for $1" >&2
    ((DOMAIN_TESTS_FAILED++))
    fi

    ((DOMAIN_TESTS_COMPLETED++))
}

checkCertificate() {
    if runOpenSSL "$1"
    then
    echo "Successfully verified certificate for $1"
    else
    echo "Could not verify certificate for $1"
    ((DOMAIN_TESTS_FAILED++))
    fi

    ((CERTIFICATE_TESTS_COMPLETED++))
}

runDomainTests() {
    local DOMAIN_TESTS_COMPLETED=0
    local DOMAIN_TESTS_FAILED=0

    checkDomain "$SINGLE_DOMAIN_INPUT"
    checkDomain "$WILDCARD_INPUT"

    echo "Getting certificates finished. Failed $DOMAIN_TESTS_FAILED, total $DOMAIN_TESTS_COMPLETED."
    if [[ "$DOMAIN_TESTS_FAILED" -ne 0 ]]
    then
    exit 1
    fi
}

runCertificateTests() {
    local CERTIFICATE_TESTS_COMPLETED=0
    local CERTIFICATE_TESTS_FAILED=0

    checkCertificate "$SINGLE_DOMAIN_INPUT"
    checkCertificate "$WILDCARD_INPUT"

    echo "Checking certificates finished. Failed $CERTIFICATE_TESTS_FAILED, total $CERTIFICATE_TESTS_COMPLETED."
    if [[ "$TESTS_FAILED" -ne 0 ]]
    then
    exit 1
    fi
}

BASE_URL="jakub.dwa-skladniki.pl"

SINGLE_DOMAIN_INPUT=$BASE_URL
WILDCARD_INPUT="*.wildcard.$BASE_URL"

runDomainTests
runCertificateTests
