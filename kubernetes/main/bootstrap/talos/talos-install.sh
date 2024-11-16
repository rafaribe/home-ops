#!/usr/bin/env bash
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.12 --file=./clusterconfig/main-tpi-1.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.13 --file=./clusterconfig/main-tpi-2.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.14 --file=./clusterconfig/main-tpi-3.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.15 --file=./clusterconfig/main-tpi-4.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.3 --file=./clusterconfig/main-srv-02.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.4 --file=./clusterconfig/main-srv-03.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.5 --file=./clusterconfig/main-srv-04.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.8 --file=./clusterconfig/main-srv-05.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.9 --file=./clusterconfig/main-srv-06.home.arpa.yaml --insecure;
talosctl apply-config --talosconfig=./clusterconfig/talosconfig --nodes=10.0.1.10 --file=./clusterconfig/main-srv-07.home.arpa.yaml --insecure;