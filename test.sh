#!/bin/bash

runLegoForDomain() {
    local ADDITIONAL_PARAMS=$1

    echo ./lego \
    --server=https://acme-staging-v02.api.letsencrypt.org/directory \
    --email="foo@bar.com" \
    --domains="example.com" \
    --dns.resolvers="ns-01.hyperone-dns.com" \
    --accept-tos \
    "$ADDITIONAL_PARAMS" \
    run
}

