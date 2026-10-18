#Requires -Version 7.0
[CmdletBinding()]
param([ValidateSet('amd64', 'arm64')][string]$Architecture = 'amd64')
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
Push-Location $Root
try {
    $Stage = Join-Path $Root 'artifacts/velmabank-delivery'
    if (Test-Path $Stage) { throw "Move existing staging directory aside first: $Stage" }
    foreach ($File in @("artifacts/velmabank-offline-$Architecture.tar.gz", 'artifacts/android/velma-baseline.apk', 'artifacts/android/velma-clone.apk', 'artifacts/android/velma-tampered.apk')) {
        if (-not (Test-Path $File)) { throw "Missing $File. Use supplied APKs or rebuild them first." }
    }
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw 'Git is required to export the committed source.' }
    $Dirty = & git status --porcelain
    if ($LASTEXITCODE -ne 0 -or $Dirty) { throw 'Commit source changes first so the source archive matches the delivery.' }
    New-Item -ItemType Directory -Force -Path "$Stage/android", "$Stage/backend", "$Stage/docs" | Out-Null
    Copy-Item artifacts/android/velma-*.apk, artifacts/android/SHA256SUMS -Destination "$Stage/android/"
    Copy-Item "artifacts/velmabank-offline-$Architecture.tar.gz" -Destination "$Stage/backend/"
    Copy-Item docs/* -Destination "$Stage/docs/" -Recurse
    $StartHere = (Get-Content docs/DELIVERY_START_HERE.md -Raw) -replace '\]\((?!https?://)([^)]+)\)', '](docs/$1)'
    [IO.File]::WriteAllText("$Stage/START_HERE.md", $StartHere, [Text.UTF8Encoding]::new($false))
    & git archive --format=zip --output="$Stage/velmabank-source.zip" HEAD
    if ($LASTEXITCODE -ne 0) { throw 'Source export failed.' }
    $Lines = Get-ChildItem $Stage -File -Recurse | Sort-Object FullName | ForEach-Object {
        $Relative = [IO.Path]::GetRelativePath($Stage, $_.FullName).Replace('\', '/')
        "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $Relative
    }
    [IO.File]::WriteAllText("$Stage/SHA256SUMS", ($Lines -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
    $Zip = Join-Path $Root 'artifacts/velmabank-delivery.zip'
    Compress-Archive -Path $Stage -DestinationPath $Zip -Force
    $Hash = (Get-FileHash $Zip -Algorithm SHA256).Hash.ToLowerInvariant()
    [IO.File]::WriteAllText("$Zip.sha256", "$Hash  velmabank-delivery.zip`n", [Text.UTF8Encoding]::new($false))
    Write-Host "Ready to upload: $Zip"
} finally { Pop-Location }
