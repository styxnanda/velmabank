# 17 — Hooking framework detection

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Vendor-approved rooted Android fixture; BlueStacks only with a compatible fixture.

[Frida Android tools](https://frida.re/docs/android/) (`frida-tools` on Windows, matching-version/ABI frida-server on the lab fixture); ADB; vendor-approved image.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Use the pre-provisioned rooted fixture and record Android ABI with `adb -s $Serial shell getprop ro.product.cpu.abi`. Verify the vendor supports this setup before attributing failures.
2. With the framework stopped, open Velma and record the clean-for-this-fixture control. Keep root allowed so it does not mask hooking detection.
3. Following the vendor fixture/Frida Android setup, start the matching frida-server on the lab device. On Windows run `frida-ls-devices`, then `frida-ps -D DEVICE_ID` to verify connectivity.
4. Reopen Velma with framework detection enabled and record whether the running server alone triggers a signal.
5. If the vendor distinguishes active attachment, obtain Velma’s PID from `adb -s $Serial shell pidof com.velma.velma_bank` and run `frida -D DEVICE_ID -p VELMA_PID`. Attach only; do not load bypass or data-collection scripts.
6. Navigate Home/Transfer, capture the event, then exit Frida. Compare running-framework versus attached-session outcomes.

## Expected result and interpretation

The vendor detects the supported installed/running/attached condition and performs its configured action.

Use matched client/server versions. Root, emulator and debugger blocks can mask the hooking case. A Frida connection failure alone is not evidence of RASP detection.

## Cleanup

Exit the attachment, stop the fixture server using its documented shutdown method, and restore the clean image.

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
