#!/usr/bin/env bash
set -e

image="ghcr.io/luca-heitmann/coder-templates/base:v1.0.0"

docker build --progress plain --platform linux/arm64 -t "$image" .
docker push "$image"
