#!/usr/bin/env bash
set -e

image="ghcr.io/luca-heitmann/coder-templates/java-19-template:v1.0.4"
template_name="java-19"

docker build --progress plain --platform linux/arm64 -t "$image" .
docker push "$image"

coder template create "$template_name" -y || coder template push "$template_name" -y
