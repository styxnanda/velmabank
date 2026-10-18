# 12 — Post-build app tampering

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Separate clean BlueStacks instance for the differently signed fixture.

Supplied `velma-baseline.apk` and `velma-tampered.apk`; BlueStacks APK installer/ADB; optional Android build-tools `apksigner`.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Record hashes of both APKs. Install baseline in the control instance, sign in, then note Lab APK asset marker and signer SHA-256.
2. Create/use a separate clean BlueStacks instance and install `velma-tampered.apk`. It changes a harmless asset and uses a different lab signer while keeping the baseline package ID.
3. Open Lab if launch succeeds. Confirm `modified-asset-v1` versus baseline `baseline-asset-v1`; confirm the signer differs.
4. After SDK integration, regenerate the fixture from the SDK-enabled baseline using the repository tamper script, then repeat with integrity/signer policy enabled.
5. Capture the vendor integrity event/action and compare against baseline signed with the enrolled lab certificate.
6. If Android refuses installation over an existing baseline, use the clean instance; do not label signature update rejection as RASP detection.

## Expected result and interpretation

The SDK-enabled modified artifact triggers the configured integrity/signer response. The supplied unprotected fixture is expected to run.

This fixture changes both content and signing identity, so it does not isolate which check fired. It does not modify money or bypass security. Original APKs predate SDK integration and cannot prove vendor detection.

## Cleanup

Delete or reset only the dedicated tamper instance. Keep baseline unchanged.

## Report

| Field | Record |
|---|---|
| Date / operator | |
| Device / Android / BlueStacks instance | |
| APK SHA-256 / signer / SDK version | |
| Policy ID / expected action | |
| Clean control result | |
| Condition and tool version | |
| Actual behavior / vendor event ID / timestamp | |
| Evidence file or screenshot reference | |
| Result: pass / fail / blocked / not_supported / not_tested | not_tested |
| Cleanup / limitation / follow-up | |

A RASP pass requires the relevant vendor event and intended action, not just a crash or failed connection. Use Lab → Record PoC evidence if the app opens; otherwise fill this file from the vendor console.

[Scenario index](../RASP_POC_GUIDE.md)
