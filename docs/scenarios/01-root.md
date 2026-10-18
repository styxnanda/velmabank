# 01 — Root / jailbroken-device detection

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Physical rooted Android fixture preferred; BlueStacks only if vendor supports that rooted image.

Android SDK Platform-Tools (`adb`); vendor-approved rooted Android fixture; a matching unrooted device/image. No iOS tools are needed.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Start on the unrooted control. Allow emulator use if applicable and disable unrelated RASP policies. Open Velma and sign in as Alice.
2. Save Lab → Refresh Android context and the successful login as the clean control.
3. Switch to the pre-provisioned rooted fixture. Connect ADB using the shared setup guide. If the fixture grants it, run `adb -s $Serial shell su -c id`; `uid=0` verifies root access. Do not change or hide root for this test.
4. Install the same SDK-enabled APK, apply the root detection policy and launch it. Attempt login if launch is allowed.
5. Capture the SDK root event and the observed action. Repeat once after restoring the clean image.

## Expected result and interpretation

Baseline may run on either device. With root blocking enabled, the rooted condition should trigger the vendor root event/action while the clean control is allowed.

An emulator event is not a root result. Stock BlueStacks is not a guaranteed root fixture. If the vendor cannot supply a rooted fixture, record not tested rather than installing an arbitrary root patch.

## Cleanup

Restore the clean instance; remove the temporary root policy override.

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
