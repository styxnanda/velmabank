# 14 — App spoofing / alternate identity

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Side-by-side BlueStacks install.

Supplied baseline and clone APKs; RASP app-identity policy; Lab signer/package fields.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Install baseline and clone side by side. Their launcher labels distinguish them.
2. Open each app and save Lab package, signer SHA-256 and build marker. Baseline package ends in `velma_bank`; clone adds `.clone`.
3. After SDK integration, enroll only the intended baseline package/signing identity in the vendor configuration. Build both flavors with the vendor’s supported settings.
4. Launch both apps under the identity policy. Record whether the alternate package is recognized/rejected as intended.
5. Separately compare case 12 if you need same-package re-signing; do not merge the two findings.

## Expected result and interpretation

The legitimate registered identity is allowed; an unregistered identity is rejected/reported if that feature is supported.

Clone is a legitimate rebuild and shares the baseline lab signer by default. Some vendor SDKs refuse to initialize in an unregistered package; record that behavior precisely. The backend does not enforce package attestation itself.

## Cleanup

Uninstall clone when finished; restore the intended SDK enrollment.

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
