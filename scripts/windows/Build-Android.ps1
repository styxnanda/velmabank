#Requires -Version 7.0
[CmdletBinding()]
param([switch]$IncludeDebug)
$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$Root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$Out = Join-Path $Root 'artifacts/android'
New-Item -ItemType Directory -Force -Path $Out | Out-Null
Push-Location (Join-Path $Root 'mobile')
try {
    & flutter pub get
    if ($LASTEXITCODE -ne 0) { throw 'flutter pub get failed.' }
    foreach ($Flavor in @('baseline', 'clone')) {
        $Marker = if ($Flavor -eq 'baseline') { 'baseline-v1' } else { 'modified-clone-v1' }
        & flutter build apk --release --flavor $Flavor "--dart-define=BUILD_MARKER=$Marker"
        if ($LASTEXITCODE -ne 0) { throw "Build failed: $Flavor" }
        Copy-Item "build/app/outputs/flutter-apk/app-$Flavor-release.apk" "$Out/velma-$Flavor.apk" -Force
    }
    if ($IncludeDebug) {
        & flutter build apk --debug --flavor baseline
        if ($LASTEXITCODE -ne 0) { throw 'Debug build failed.' }
        Copy-Item 'build/app/outputs/flutter-apk/app-baseline-debug.apk' "$Out/velma-debug.apk" -Force
    }
    Write-Host 'Existing tampered APKs are not regenerated here; regenerate after each baseline/SDK change.'
    $Lines = Get-ChildItem "$Out/velma-*.apk" | Sort-Object Name | ForEach-Object { "{0}  {1}" -f (Get-FileHash $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant(), $_.Name }
    [IO.File]::WriteAllText("$Out/SHA256SUMS", ($Lines -join "`n") + "`n", [Text.UTF8Encoding]::new($false))
} finally { Pop-Location }
