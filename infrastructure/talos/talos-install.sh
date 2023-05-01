#!/usr/bin/env bash

talosctl apply --insecure -n 10.0.1.12 --file clusterconfig/skovald-talos1.rafaribe.site.yaml
talosctl apply --insecure -n 10.0.1.13 --file clusterconfig/skovald-talos2.rafaribe.site.yaml
talosctl apply --insecure -n 10.0.1.14 --file clusterconfig/skovald-talos3.rafaribe.site.yaml
talosctl apply --insecure -n 10.0.1.15 --file clusterconfig/skovald-talos4.rafaribe.site.yaml
