# 13 — Application blacklisting

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks; benign installed application fixture.

Supplied `velma-clone.apk` as a benign blacklist fixture; RASP console; ADB/BlueStacks installer.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. On the baseline instance, ensure clone is absent. Sign in successfully and record the control.
2. Add the exact package `com.velma.velma_bank.clone` to the SDK application blacklist for baseline Velma.
3. Install `velma-clone.apk` alongside baseline. You do not need to launch the clone.
4. Force-stop/reopen baseline Velma and attempt sign-in. Capture the package-blacklist event and intended action.
5. Uninstall only the clone with `adb -s $Serial uninstall com.velma.velma_bank.clone`, then reopen baseline and confirm access returns.

## Expected result and interpretation

Presence of the specified package triggers blacklist enforcement; absence clears it.

This is an installed-package policy test, not malware classification. SDK package visibility requirements must be configured during integration.

## Cleanup

Remove the temporary blacklist entry and ensure the clone is uninstalled.

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
