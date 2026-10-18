#Requires -Version 7.0
[CmdletBinding()]
param(
    [ValidateSet('amd64', 'arm64')][string]$Architecture = 'amd64',
    [ValidatePattern('^[a-zA-Z0-9.-]+$')][string]$ServerHost = 'localhost'
)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location $Root
try {
    foreach ($Command in @('docker', 'tar')) {
        if (-not (Get-Command $Command -ErrorAction SilentlyContinue)) { throw "$Command is required; see docs/WINDOWS_PREP.md" }
    }
    $OsType = & docker info --format '{{.OSType}}'
    if ($LASTEXITCODE -ne 0 -or $OsType -ne 'linux') { throw 'Start Docker Desktop in Linux containers mode.' }
    & docker compose version
    if ($LASTEXITCODE -ne 0) { throw 'Docker Compose v2 is required.' }
    & docker buildx version
    if ($LASTEXITCODE -ne 0) { throw 'Docker Buildx is required.' }
    $Out = Join-Path $Root "artifacts/velmabank-offline-$Architecture"
    # Never mix a prior export/certificate set with a new one.
    if (Test-Path $Out) { throw "Output exists: $Out. Move it aside before preparing a fresh bundle." }
    New-Item -ItemType Directory -Force -Path "$Out/deploy/certs", "$Out/docs" | Out-Null
    & docker buildx build --platform "linux/$Architecture" --load -t velmabank-api:1.0.0 backend
    if ($LASTEXITCODE -ne 0) { throw 'Backend image build failed.' }
    & docker pull --platform "linux/$Architecture" nginx:1.28-alpine
    if ($LASTEXITCODE -ne 0) { throw 'nginx download failed.' }
    $CertDir = (Resolve-Path "$Out/deploy/certs").Path
    & docker run --rm --pull never --platform "linux/$Architecture" --user 0:0 --entrypoint python --mount "type=bind,source=$CertDir,target=/certs" velmabank-api:1.0.0 -m app.certificates $ServerHost
    if ($LASTEXITCODE -ne 0) { throw 'Certificate generation failed.' }
    # Use a file, not a PowerShell binary pipeline: no tar-stream encoding corruption.
    & docker save --platform "linux/$Architecture" --output "$Out/images.tar" velmabank-api:1.0.0 nginx:1.28-alpine
    if ($LASTEXITCODE -ne 0) { throw 'Image export failed. Update Docker Desktop if --platform is unsupported.' }
    Copy-Item compose.yaml, README.md -Destination $Out
    Copy-Item deploy/nginx.conf -Destination "$Out/deploy/"
    Copy-Item docs/* -Destination "$Out/docs/" -Recurse
    Copy-Item scripts/start-offline.sh, scripts/configure-tls.sh -Destination $Out
    $Utf8 = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText("$Out/PLATFORM.txt", "linux/$Architecture`n", $Utf8)
    $Files = @('images.tar', 'compose.yaml', 'deploy/nginx.conf', 'deploy/certs/ca.crt', 'deploy/certs/server.crt', 'deploy/certs/server.key')
    $Lines = foreach ($File in $Files) { "{0}  {1}" -f (Get-FileHash "$Out/$File" -Algorithm SHA256).Hash.ToLowerInvariant(), $File }
    [System.IO.File]::WriteAllText("$Out/SHA256SUMS", ($Lines -join "`n") + "`n", $Utf8)
    & tar -czf "$Out.tar.gz" -C (Join-Path $Root 'artifacts') "velmabank-offline-$Architecture"
    if ($LASTEXITCODE -ne 0) { throw 'Archive creation failed.' }
    Write-Host "Ready: $Out.tar.gz"
    Write-Host 'Transfer to Linux; extract, then run: bash start-offline.sh'
    Write-Host 'Unknown final IP is fine. On Linux: bash configure-tls.sh SERVER_IP --replace'
} finally { Pop-Location }
