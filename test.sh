#!/bin/bash

runLego() {
    ./lego \
    --server "https://acme-staging-v02.api.letsencrypt.org/directory" \
    --email "foo@bar.com" \
    --dns.resolvers "ns-01.hyperone-dns.com" \
    --dns "hyperone" \
    --accept-tos \
    --domains "$1" \
    --domains "$2" \
    run
}

runOpenSSL() {
    local CERT_NAME="${1//\*/_}" # replace "*"" with "_" for wildcards
    local CERT_PATH="/lego/.lego/certificates/$CERT_NAME.crt"
    openssl verify -partial_chain -trusted "$CERT_PATH" "$CERT_PATH"
}

checkDomain() { 
    if runLego "$1" "$2"
    then
    echo "Successfully got certificate for $1 and $2"
    else
    echo "Could not get certificate for $1 and/or $2" >&2
    ((DOMAIN_TESTS_FAILED++))
    fi

    ((DOMAIN_TESTS_COMPLETED++))
}

checkCertificate() {
    if runOpenSSL "$1"
    then
    echo "Successfully verified certificate for $1"
    else
    echo "Could not verify certificate for $1" >&2
    ((CERTIFICATE_TESTS_FAILED++))
    fi

    ((CERTIFICATE_TESTS_COMPLETED++))
}

runDomainTests() {
    local DOMAIN_TESTS_COMPLETED=0
    local DOMAIN_TESTS_FAILED=0

    checkDomain "$SINGLE_DOMAIN_INPUT" "$WILDCARD_INPUT"
    checkDomain "$ALIAS_INPUT" "$ALIAS_WILDCARD_INPUT"

    echo "Getting certificates finished. Failed $DOMAIN_TESTS_FAILED, total $DOMAIN_TESTS_COMPLETED."
    if [[ "$DOMAIN_TESTS_FAILED" -ne 0 ]]
    then
    exit 1
    fi
}

runCertificateTests() {
    local CERTIFICATE_TESTS_COMPLETED=0
    local CERTIFICATE_TESTS_FAILED=0

    # as far as I understand, certificate name is dependent on first domain
    checkCertificate "$SINGLE_DOMAIN_INPUT"
    checkCertificate "$ALIAS_INPUT"

    echo "Checking certificates finished. Failed $CERTIFICATE_TESTS_FAILED, total $CERTIFICATE_TESTS_COMPLETED."
    if [[ "$CERTIFICATE_TESTS_FAILED" -ne 0 ]]
    then
    exit 1
    fi
}

if [ -z "$BASE_URL" ]
then
    BASE_URL="jakub.dwa-skladniki.pl"
fi

if [ -z "$ALIAS_URL" ]
then
    ALIAS_URL="jakub2.dwa-skladniki.pl"
fi

SINGLE_DOMAIN_INPUT=$BASE_URL
WILDCARD_INPUT="*.$BASE_URL"
ALIAS_INPUT=$ALIAS_URL
ALIAS_WILDCARD_INPUT="*.$ALIAS_URL"

runDomainTests
runCertificateTests
