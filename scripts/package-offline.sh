#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
ARCH="${1:-amd64}"
[[ "$ARCH" == amd64 || "$ARCH" == arm64 ]] || { echo 'Use amd64 or arm64'; exit 1; }
[[ -f deploy/certs/server.key ]] || { echo 'Run scripts/make-certs.sh SERVER_IP first'; exit 1; }
OUT="artifacts/velmabank-offline-$ARCH"
mkdir -p "$OUT/deploy/certs" "$OUT/docs"
docker buildx build --platform "linux/$ARCH" --load -t velmabank-api:1.0.0 backend
docker pull --platform "linux/$ARCH" nginx:1.28-alpine
docker save --platform "linux/$ARCH" velmabank-api:1.0.0 nginx:1.28-alpine | gzip > "$OUT/images.tar.gz"
cp compose.yaml "$OUT/"
cp deploy/nginx.conf "$OUT/deploy/"
cp deploy/certs/{ca.crt,server.crt,server.key} "$OUT/deploy/certs/"
cp -R docs/. "$OUT/docs/"
cp README.md "$OUT/"
cp scripts/start-offline.sh scripts/configure-tls.sh "$OUT/"
printf 'linux/%s\n' "$ARCH" > "$OUT/PLATFORM.txt"
(cd "$OUT"
 if command -v sha256sum >/dev/null; then
   sha256sum images.tar.gz compose.yaml deploy/nginx.conf deploy/certs/* > SHA256SUMS
 else
   shasum -a 256 images.tar.gz compose.yaml deploy/nginx.conf deploy/certs/* > SHA256SUMS
 fi)
tar -czf "$OUT.tar.gz" -C artifacts "velmabank-offline-$ARCH"
echo "Ready: $OUT.tar.gz (contains lab TLS private key; keep within your test team)"
