#!/usr/bin/env bash
flux bootstrap github \
    --owner=rafaribe \
    --repository=home-ops \
    --branch=main \
    --path=kubernetes/clusters/delta/flux \
    --read-write-key \
    --token-auth

# flux bootstrap github \
#     --owner=rafaribe \
#     --repository=home-ops \
#     --branch=main \
#     --path=kubernetes/clusters/delta/flux \
#     --read-write-key \
#     --token-auth
