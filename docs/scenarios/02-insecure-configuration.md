# 02 — Insecure configuration / ADB

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks plus Android settings; device behavior may vary by guest image.

BlueStacks 5 Settings → Advanced → Android Debug Bridge; Android Developer Options; `adb`.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Enable Developer Options but initially keep Android USB debugging off if the guest exposes that setting. Sign in and save Lab device context.
2. Configure the SDK to report/block USB debugging or ADB specifically, while allowing Developer Options itself.
3. Enable BlueStacks ADB to connect the host, and separately enable Android USB debugging if available. Refresh context; record `adbEnabled` and `developerOptionsEnabled` independently.
4. Force-stop/reopen Velma from the Android app UI and attempt sign-in. Capture the insecure-configuration event.
5. Turn the Android debugging setting off and repeat via the UI. Disabling BlueStacks ADB may disconnect your host; use the app UI for this control.

## Expected result and interpretation

Only the configured insecure setting should cause the intended action. Developer Options alone remains allowed in case 24.

BlueStacks host ADB connectivity and Android `ADB_ENABLED` can differ. A reachable ADB port is not proof of the setting or policy the SDK actually inspects.

## Cleanup

Restore initial debugging settings and remove the temporary policy; reconnect ADB only when needed.

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
