#! /usr/bin/env fish

helmfile template --quiet helmfile-crds.yaml | kubectl apply --server-side --filename -
sleep 2
helmfile apply
sleep 30
helmfile apply -f helmfile-post.yaml 