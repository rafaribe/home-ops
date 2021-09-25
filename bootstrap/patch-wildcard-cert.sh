#!/usr/bin/env bash

kubectl annotate secret wildcard-certificate-tls --namespace networking --overwrite replicator.v1.mittwald.de/replicate-to=networking,crypto,observability
