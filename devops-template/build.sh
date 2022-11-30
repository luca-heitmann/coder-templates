#!/usr/bin/env bash
set -e

image="ghcr.io/luca-heitmann/coder-templates/devops-template:v1.0.0"
template_name="devops"

docker build --progress plain --platform linux/arm64 -t "$image" .
docker push "$image"

coder template create "$template_name" -y || coder template push "$template_name" -y
