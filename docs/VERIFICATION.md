# Verification record

Date: 2026-10-18 (Asia/Jakarta).

## Passed

- Flutter static analysis: no issues.
- Flutter widget smoke check on a 360 × 740 logical-pixel viewport: login screen, connection dialog and save flow; no layout exceptions.
- App's real Dart API client against the Docker backend over HTTP and separately over HTTPS with explicit private-CA certificate validation:
  - Alice/Bob authentication and distinct session keys.
  - Transfer preparation, lab inbox and OTP confirmation.
  - Exactly-once debit on repeated confirmation, matching recipient credit.
  - Cross-user transfer confirmation rejected.
  - Persistent card freeze/unfreeze.
  - Dart AES-GCM encryption → Python decryption → Python encryption → Dart authenticated decryption.
  - Another user's session cannot decrypt the envelope.
  - Evidence saving/readback.
  - Logout revocation and key/token rotation at next login.
- HTTPS health request with CA and hostname verification.
- Linux amd64 API and nginx image export and reload from the offline archive.
- Certificate generation inside the bundled API image with `--network none`; generated IP certificate verified against its generated CA.
- Python source compilation and shell syntax checks.
- Baseline and clone release APK builds (Flutter 3.47.4), including ARMv7/ARM64/x86-64 libraries.
- Controlled post-build modified APK: patched marker confirmed; APK v2/v3 signatures verified. Baseline and clone signatures also verified.
- APK identity inspection: baseline `com.velma.velma_bank`, clone `com.velma.velma_bank.clone`, modified fixture keeps baseline ID with a distinct signer.

The API/nginx containers were exercised on the Mac's Linux Docker VM using amd64 emulation. A clean deployment seeds fresh balances; the test database is a local Docker volume and is not embedded in the image/archive.

## Boundaries

No BlueStacks device or physical Android device was available here. Android install/launch and native permission behavior must be checked on your target instance. There has been no vulnerability testing, RASP detection validation, load testing or broad security audit. The SDK remains deliberately unintegrated. The workbook marks physical-device-only or vendor-dependent cases explicitly.

## Generated APK checksums

```text
4311bb0e0b57226c9e601df763c5db257194f3a87432372e981fdc7e6b5f818f  velma-baseline.apk
ee207405d71a853017395c5233f183cba3f3328f2de5cddc68d516123b2c85c8  velma-clone.apk
44a12510e3a70490140a00d61de0b38e79faf7576932b4f483107f1c45af4d63  velma-tampered.apk
```

## Windows handoff update

- Added five PowerShell 7 scripts for local backend preparation, remote SSH preparation, optional Android builds, optional Burp certificate export and final ZIP assembly.
- All five scripts parsed successfully with PowerShell 7.6.7 on macOS.
- Executed `Prepare-Backend.ps1` from an isolated source copy against Docker: image build/export, in-container certificates, tar packaging and all generated SHA-256 checks passed. This exercised PowerShell logic on macOS, not a Windows desktop.
- Shell syntax checks and relative Markdown link checks passed; 24 individual scenario reports plus shared BlueStacks setup are present.
- Windows/BlueStacks execution and a real remote SSH builder were not available here; those paths have not been run on the target systems. No RASP or vulnerability scenarios were executed.
