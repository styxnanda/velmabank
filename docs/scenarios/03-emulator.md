# 03 — Emulator detection

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks on Windows, plus a physical Android negative control.

BlueStacks 5; physical Android phone; APK install UI or `adb`.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Install the same SDK-enabled baseline APK in BlueStacks and on a physical control device.
2. With emulator detection in report-only/allowed mode, sign in on both and record Lab manufacturer, model and Android API.
3. Enable the RASP emulator-blocking policy for this case only.
4. Close and reopen Velma in BlueStacks. Record launch/login behavior and the corresponding emulator event.
5. Repeat on the physical control and confirm that it remains usable.
6. Return emulator policy to allowed before running any other cases.

## Expected result and interpretation

BlueStacks is identified according to vendor support and blocked/reported as configured; the physical control is not flagged as an emulator.

A block at launch cannot be recorded in the app. Use the vendor console and this report. Run this case last to avoid masking other tests.

## Cleanup

Re-allow emulator usage and confirm a successful BlueStacks login.

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
