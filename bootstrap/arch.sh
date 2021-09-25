#!/usr/bin/env bash

kubectl label nodes sala arch=arm --overwrite
kubectl label nodes sala beta.kubernetes.io/arch=arm --overwrite
kubectl label nodes sala kubernetes.io/arch=arm --overwrite

kubectl label nodes octoprint arch=arm --overwrite
kubectl label nodes octoprint beta.kubernetes.io/arch=arm --overwrite
kubectl label nodes octoprint kubernetes.io/arch=arm --overwrite
