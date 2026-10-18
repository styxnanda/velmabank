# 18 — Keylogger prevention / sensitive input

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Vendor-supplied non-exfiltrating accessibility or IME fixture.

Harmless vendor keylogger simulation APK; Android Accessibility/keyboard settings; dummy Velma inputs.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Obtain the fixture’s package/hash and documentation describing how it signals a keylogging condition without collecting real data.
2. With its service disabled, sign in and enter a dummy payment note. Save the allowed control.
3. Enable only the fixture’s documented Accessibility service or input method. Do not enable unrelated services.
4. Open Velma’s login and note fields; type `VELMA-LAB-ONLY`. Record whether the SDK blocks input, warns, or closes the app, plus the vendor event.
5. Disable the service/IME and repeat. If the vendor provides a local no-network capture indicator, record whether synthetic text reached it as a separate observation.

## Expected result and interpretation

The configured sensitive-entry policy triggers on the supported fixture and clears after it is disabled.

Package presence, accessibility permission and actual input interception are different claims. Without a safe fixture, record not tested; an auto-clicker is not proof of keylogging.

## Cleanup

Disable and uninstall the fixture; restore the original keyboard/accessibility settings.

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
