#!/usr/bin/env bash
# Runs on the online Linux Docker builder, invoked from Windows over SSH.
set -euo pipefail
cd "$(dirname "$0")/.."
ARCH="${1:-amd64}"
SERVER_HOST="${2:-localhost}"
[[ "$ARCH" == amd64 || "$ARCH" == arm64 ]] || { echo 'Use amd64 or arm64'; exit 1; }
[[ "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]] || { echo 'Invalid host'; exit 1; }
mkdir -p deploy/certs
docker buildx build --platform "linux/$ARCH" --load -t velmabank-api:1.0.0 backend
docker run --rm --pull never --network none --platform "linux/$ARCH" --user "$(id -u):$(id -g)" --entrypoint python -v "$PWD/deploy/certs:/certs" velmabank-api:1.0.0 -m app.certificates "$SERVER_HOST"
bash scripts/package-offline.sh "$ARCH"
