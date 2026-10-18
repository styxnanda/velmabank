#Requires -Version 7.0
[CmdletBinding()]
param(
    [Parameter(Mandatory)][ValidatePattern('^[a-zA-Z0-9_.-]+@[a-zA-Z0-9.-]+$')][string]$Builder,
    [ValidateSet('amd64', 'arm64')][string]$Architecture = 'amd64',
    [ValidatePattern('^[a-zA-Z0-9.-]+$')][string]$ServerHost = 'localhost'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location $Root
try {
    foreach ($Command in @('ssh', 'scp', 'tar')) {
        if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) { throw "$Command is required. See docs/WINDOWS_PREP.md." }
    }
    $Result = Join-Path $Root "artifacts/velmabank-offline-$Architecture.tar.gz"
    if (Test-Path $Result) { throw "Move existing $Result aside before rebuilding." }
    New-Item -ItemType Directory -Force artifacts | Out-Null
    $SourceArchive = Join-Path $Root 'artifacts/velma-backend-source.tar.gz'
    # Allowlisted sources only: excludes local TLS/signing keys and data.
    & tar -czf $SourceArchive backend scripts docs compose.yaml README.md deploy/nginx.conf
    if ($LASTEXITCODE -ne 0) { throw 'Source archive creation failed.' }
    & ssh $Builder 'docker info --format "{{.OSType}}" && docker buildx version && docker compose version'
    if ($LASTEXITCODE -ne 0) { throw 'Builder needs reachable Docker Engine, Buildx and Compose v2 without interactive sudo.' }
    $Remote = (& ssh $Builder 'mktemp -d /tmp/velma-prep.XXXXXXXXXX' | Out-String).Trim()
    if ($LASTEXITCODE -ne 0 -or $Remote -notmatch '^/tmp/velma-prep\.[a-zA-Z0-9]+$') { throw 'Could not obtain a clean remote build directory.' }
    & scp $SourceArchive "${Builder}:$Remote/source.tar.gz"
    if ($LASTEXITCODE -ne 0) { throw 'Source transfer failed.' }
    & ssh $Builder "cd '$Remote' && tar -xzf source.tar.gz && bash scripts/prepare-backend-remote.sh '$Architecture' '$ServerHost'"
    if ($LASTEXITCODE -ne 0) { throw "Remote build failed. Files remain at ${Builder}:$Remote" }
    & scp "${Builder}:$Remote/artifacts/velmabank-offline-$Architecture.tar.gz" $Result
    if ($LASTEXITCODE -ne 0) { throw 'Downloading result failed.' }
    Write-Host "Ready on Windows: $Result"
    Write-Host "The image was built on Linux, orchestrated from this PC. Remote work directory: ${Builder}:$Remote"
    Write-Host 'No Docker, Flutter, Java, or Python is required on Windows for this path.'
} finally { Pop-Location }
