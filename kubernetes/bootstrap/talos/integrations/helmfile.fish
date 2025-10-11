#! /usr/bin/env fish

helmfile apply -f helmfile-crds.yaml
sleep 2
helmfile apply
sleep 30
helmfile apply -f helmfile-post.yaml 