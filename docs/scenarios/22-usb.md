# 22 — USB / juice-jacking risk signals

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Physical Android and a trusted Windows lab workstation required.

USB data cable; Android USB preferences; Windows workstation; ADB optional. No hostile charger or USB payload.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Disconnect USB. Open Velma and save a normal login control.
2. Attach the phone to the trusted workstation in charge-only/no-data mode. Refresh/open Velma and record vendor USB context or events.
3. Change Android USB preference to File transfer. Reopen Velma and repeat the same action under the configured USB-risk policy.
4. If the policy explicitly covers ADB, separately enable USB debugging and authorize only this lab workstation; record that subcase.
5. Return to charge-only, then disconnect; verify the app recovers.

## Expected result and interpretation

Supported USB data/ADB risk states produce the vendor’s configured signal/action.

A USB connection or debugging event is not proof of malicious-charging-station detection. BlueStacks cannot represent the physical power/data path; mark not_supported there.

## Cleanup

Return USB to no-data mode, disable test debugging, and revoke the workstation authorization if it was temporary.

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
