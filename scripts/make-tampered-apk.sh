#!/usr/bin/env bash
# Harmless lab fixture: patch one Flutter asset, re-align and re-sign a copy.
set -euo pipefail
cd "$(dirname "$0")/.."
SDK="${ANDROID_HOME:-${ANDROID_SDK_ROOT:-}}"
[[ -n "$SDK" ]] || { echo 'Set ANDROID_HOME to your Android SDK'; exit 1; }
TOOLS="$(find "$SDK/build-tools" -mindepth 1 -maxdepth 1 -type d | sort | tail -1)"
[[ -x "$TOOLS/apksigner" ]] || { echo 'Android build-tools required'; exit 1; }
INPUT="${1:-artifacts/android/velma-baseline.apk}"
OUT=artifacts/android
mkdir -p "$OUT"
python3 - "$INPUT" "$OUT/tampered-unsigned.apk" <<'PY'
from pathlib import Path
import sys
import zipfile
marker = 'assets/flutter_assets/assets/integrity_marker.txt'
with zipfile.ZipFile(sys.argv[1]) as source, zipfile.ZipFile(sys.argv[2], 'w') as target:
    if marker not in source.namelist():
        raise SystemExit('Baseline APK is missing the controlled marker asset')
    for entry in source.infolist():
        # Remove old JAR signatures; rewriting ZIP also removes the v2 signing block.
        if entry.filename.startswith('META-INF/') and entry.filename.upper().endswith(('.RSA', '.DSA', '.EC', '.SF', 'MANIFEST.MF')):
            continue
        data = b'modified-asset-v1\n' if entry.filename == marker else source.read(entry.filename)
        target.writestr(entry, data)
PY
"$TOOLS/zipalign" -P 16 -f 4 "$OUT/tampered-unsigned.apk" "$OUT/tampered-aligned.apk"
if [[ ! -f artifacts/tamper-lab.jks ]]; then
  keytool -genkeypair -keystore artifacts/tamper-lab.jks -storepass android -keypass android -alias tamper-lab -keyalg RSA -keysize 2048 -validity 3650 -dname 'CN=Velma Tamper Lab' -noprompt
fi
"$TOOLS/apksigner" sign --ks artifacts/tamper-lab.jks --ks-key-alias tamper-lab --ks-pass pass:android --key-pass pass:android --out "$OUT/velma-tampered.apk" "$OUT/tampered-aligned.apk"
"$TOOLS/apksigner" verify --verbose "$OUT/velma-tampered.apk"
rm "$OUT/tampered-unsigned.apk" "$OUT/tampered-aligned.apk"
(cd "$OUT" && shasum -a 256 velma-*.apk > SHA256SUMS)
echo 'Created velma-tampered.apk: same package, changed asset, different lab signer. Use a separate clean emulator snapshot.'
