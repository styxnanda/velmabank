#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if command -v sha256sum >/dev/null; then sha256sum -c SHA256SUMS; else shasum -a 256 -c SHA256SUMS; fi
ACTUAL="$(docker info --format '{{.Architecture}}')"
case "$ACTUAL" in x86_64) ACTUAL=amd64;; aarch64) ACTUAL=arm64;; esac
[[ "linux/$ACTUAL" == "$(cat PLATFORM.txt)" ]] || { echo "Wrong bundle for host architecture: $ACTUAL"; exit 1; }
gunzip -c images.tar.gz | docker load
docker compose up -d --pull never --no-build
echo 'Velma API: http://SERVER_IP:8080 ; TLS: https://SERVER_IP:8443'
echo 'Check: docker compose ps ; docker compose logs --tail=50'
