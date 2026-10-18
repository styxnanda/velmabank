#Requires -Version 7.0
[CmdletBinding()]
param([Parameter(Mandatory)][ValidatePattern('^[a-zA-Z0-9.-]+$')][string]$WindowsHost)
$ErrorActionPreference = 'Stop'
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$Out = Join-Path $Root 'artifacts/burp-tls'
if (Test-Path $Out) { throw "Move existing $Out aside before generating a new certificate." }
New-Item -ItemType Directory -Path $Out -Force | Out-Null
& docker run --rm --pull never --user 0:0 --entrypoint python --mount "type=bind,source=$Out,target=/certs" velmabank-api:1.0.0 -m app.certificates $WindowsHost
if ($LASTEXITCODE -ne 0) { throw 'Certificate generation failed. Load/build the Velma API image first.' }
$Python = @'
from pathlib import Path
from cryptography import x509
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.serialization import pkcs12
p = Path('/certs')
key = serialization.load_pem_private_key((p/'server.key').read_bytes(), password=None)
cert = x509.load_pem_x509_certificate((p/'server.crt').read_bytes())
ca = x509.load_pem_x509_certificate((p/'ca.crt').read_bytes())
(p/'burp-listener.p12').write_bytes(pkcs12.serialize_key_and_certificates(b'velma-lab', key, cert, [ca], serialization.BestAvailableEncryption(b'velma-lab')))
'@
& docker run --rm --pull never --user 0:0 --entrypoint python --mount "type=bind,source=$Out,target=/certs" velmabank-api:1.0.0 -c $Python
if ($LASTEXITCODE -ne 0) { throw 'PKCS12 export failed.' }
Write-Host "Import $Out/burp-listener.p12 into the Burp listener (password: velma-lab)."
Write-Host 'Paste ca.crt into Velma Connection settings only for the trusted-interception phase.'
