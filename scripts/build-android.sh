#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p artifacts/android
cd mobile
flutter pub get
flutter build apk --release --flavor baseline --dart-define=BUILD_MARKER=baseline-v1
cp build/app/outputs/flutter-apk/app-baseline-release.apk ../artifacts/android/velma-baseline.apk
flutter build apk --release --flavor clone --dart-define=BUILD_MARKER=modified-clone-v1
cp build/app/outputs/flutter-apk/app-clone-release.apk ../artifacts/android/velma-clone.apk
cd ../artifacts/android
shasum -a 256 *.apk > SHA256SUMS
