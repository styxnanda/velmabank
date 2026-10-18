# 04 — Anti-debugging

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks with a debug build; Android Studio on Windows.

Android Studio debugger; Platform-Tools; Flutter/Java/Android SDK only to build the debug APK. See Windows prep guide.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Build with `pwsh -File .\scripts\windows\Build-Android.ps1 -IncludeDebug`, or obtain the matching SDK-enabled debug build. Keep release APK for the release control.
2. Install `velma-debug.apk` on a separate instance. Configure the SDK to allow debuggable builds but report/block an attached debugger, if it supports distinct policies.
3. Launch without attachment and sign in. Record Lab → `debuggable` and `debuggerAttached`.
4. In Android Studio, open the Android project and use Run → Attach debugger to Android process; select `com.velma.velma_bank`. Attach a Java/Kotlin debugger.
5. Refresh Lab context and attempt a transfer. Capture the attached-debugger event/action.
6. Detach, force-stop and reopen. Repeat without the debugger, then compare with the release build.

## Expected result and interpretation

An actual debugger attachment produces the configured event/action. A build marked debuggable is a separate finding.

Normal release builds are non-debuggable; failure to attach to release is an OS/build control, not RASP detection. If the vendor blocks all debug builds before attachment, report that narrower result.

## Cleanup

Detach debugger; restore the release APK and clean policy.

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
