# 07 — Insecure Wi-Fi

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Physical Android device required for a meaningful AP-security test.

Team-owned configurable Wi-Fi router/AP; Android Wi-Fi settings; backend reachable on both test networks.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Connect the device to the secured lab SSID (WPA2/WPA3). Configure backend HTTPS and sign in.
2. Enable the SDK insecure-Wi-Fi policy and record that the secured control stays allowed.
3. Configure a separate isolated open SSID on the lab AP. Keep backend routing available; avoid changing the backend certificate/origin.
4. Connect the phone to the open SSID, reopen Velma and refresh Home. Record the vendor Wi-Fi-security event/action.
5. Reconnect to the secured SSID and repeat to confirm the condition clears.

## Expected result and interpretation

Open Wi-Fi produces the intended warning/block, while secured Wi-Fi is allowed.

BlueStacks virtual networking does not reliably expose the Windows host’s AP security to Android. Backend routing failure is not detection; check network reachability independently.

## Cleanup

Disable the open SSID and return the phone to the secured lab network.

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
