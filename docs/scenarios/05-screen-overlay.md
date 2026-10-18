# 05 — Screen mirroring and overlays

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Android-side capture/overlay; Windows desktop capture is outside guest scope.

[scrcpy for Windows](https://github.com/Genymobile/scrcpy/blob/master/doc/windows.md); ADB; the floating control panel of the benign auto-clicker from case 23 (automation OFF).

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. In Velma Lab keep OS secure-window control OFF. Open Home and confirm that a normal screenshot works as a baseline.
2. Run `scrcpy -s $Serial` on Windows. Show Home and Transfer; record whether the guest app is visible.
3. Enable the SDK screen-capture/mirroring policy, restart the app and repeat. Save the vendor event separately from the visible output.
4. Stop scrcpy. In the auto-clicker app grant Draw over other apps, show its floating panel but leave automated tapping OFF. Place it over a harmless area of the Transfer page.
5. Enable the SDK overlay policy and reopen Velma. Record whether the overlay is rejected, taps are blocked, or the app is stopped as configured.
6. As a separate OS control only, turn secure-window ON and repeat mirroring. Do not count this OS result as SDK enforcement.

## Expected result and interpretation

The vendor detects or restricts supported capture/overlay paths under the appropriate policy.

scrcpy uses an Android capture path that may differ from MediaProjection. If unsupported, use case 21 for a MediaProjection fixture. Capturing the BlueStacks window on Windows may be invisible to Android.

## Cleanup

Stop scrcpy and the floating panel, revoke its overlay permission, and turn secure-window OFF.

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
