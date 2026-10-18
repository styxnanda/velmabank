#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
SERVER_HOST="${1:-localhost}"
if [[ ! "$SERVER_HOST" =~ ^[a-zA-Z0-9.-]+$ ]]; then echo 'Supply a DNS hostname or IPv4 address (no port).'; exit 1; fi
if [[ -e deploy/certs/server.key ]]; then echo 'Certificates already exist. Move them aside deliberately to rotate.'; exit 1; fi
mkdir -p deploy/certs
umask 077
openssl req -x509 -newkey rsa:2048 -nodes -sha256 -days 365 -keyout deploy/certs/ca.key -out deploy/certs/ca.crt -subj '/CN=Velma Bank Lab CA'
openssl req -newkey rsa:2048 -nodes -keyout deploy/certs/server.key -out deploy/certs/server.csr -subj "/CN=$SERVER_HOST"
SAN="DNS:localhost,IP:127.0.0.1,IP:10.0.2.2"
if [[ "$SERVER_HOST" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then SAN="$SAN,IP:$SERVER_HOST"; else SAN="$SAN,DNS:$SERVER_HOST"; fi
printf 'subjectAltName=%s\nextendedKeyUsage=serverAuth\nbasicConstraints=CA:FALSE\n' "$SAN" > deploy/certs/server.ext
openssl x509 -req -in deploy/certs/server.csr -CA deploy/certs/ca.crt -CAkey deploy/certs/ca.key -CAcreateserial -out deploy/certs/server.crt -days 365 -sha256 -extfile deploy/certs/server.ext
chmod 644 deploy/certs/ca.crt deploy/certs/server.crt
printf 'Created certificates for %s. Paste deploy/certs/ca.crt into app Connection settings.\n' "$SERVER_HOST"
