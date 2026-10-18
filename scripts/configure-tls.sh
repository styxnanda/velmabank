#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
[[ -f compose.yaml ]] || cd ..
[[ $# -ge 1 ]] || { echo 'Usage: configure-tls.sh SERVER_IP_OR_HOSTNAME [--replace]'; exit 1; }
mkdir -p deploy/certs
docker run --rm --pull never --user "$(id -u):$(id -g)" --entrypoint python -v "$PWD/deploy/certs:/certs" velmabank-api:1.0.0 -m app.certificates "$@"
echo 'If already running: docker compose restart tls'
