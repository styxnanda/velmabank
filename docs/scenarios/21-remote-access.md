# 21 — Screen sharing / remote access

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Android-side projection or remote-control service; physical device fallback.

scrcpy on Windows for an ADB remote-control subcase; vendor-approved Android MediaProjection/remote-support test app and its viewer for the projection subcase.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Keep Velma OS secure-window OFF. With no capture session, open Home/Card and save the control.
2. For ADB remote control, start `scrcpy -s $Serial` and use the mirrored UI to navigate Home → Transfer. Record the vendor’s supported remote-control event/action.
3. Stop scrcpy. Start the approved Android projection fixture and accept the Android screen-sharing prompt. Connect its team-controlled viewer.
4. Open Velma and repeat Home/Card/Transfer with the SDK remote-access policy enabled. Record the event and whether sensitive content/input is blocked.
5. Stop the projection through the Android notification and repeat to confirm recovery.

## Expected result and interpretation

The relevant supported guest capture/control session triggers the configured restriction.

ADB control and MediaProjection are separate paths. Windows RDP/OBS capturing the BlueStacks window may be invisible to guest Android. If no approved projection fixture is available, mark that subcase not tested rather than substituting host capture.

## Cleanup

End capture/control sessions, revoke the test app’s permissions and restore normal policy.

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
