# 11 — Anti-reverse-engineering / static inspection

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Windows offline APK inspection.

[JADX GUI](https://github.com/skylot/jadx/releases); Android Studio APK Analyzer; baseline and later SDK-protected APKs.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Copy both APKs into separate folders and record SHA-256 hashes with `Get-FileHash -Algorithm SHA256`.
2. Open baseline in Android Studio → Build → Analyze APK. Inspect AndroidManifest, DEX files, native libraries and the Flutter marker asset.
3. Open baseline in JADX GUI. Locate the Java/Kotlin Android bridge and recognizable package/class names.
4. Repeat with the SDK-enabled release APK using the same build mode and signing policy. Compare only protections the vendor claims: wrapper naming, protected assets, native protection or its documented metrics.
5. Record readable versus protected elements with screenshots. If the vendor supplies a runtime anti-analysis fixture, run it as a separate subcase and record the runtime event.

## Expected result and interpretation

Observed static protection matches the vendor’s documented scope. Runtime detection is only expected for a supported runtime condition.

JADX decompiles DEX, not Flutter AOT Dart code into its original source. Obfuscation/readability differences alone are not proof of resistance to reverse engineering. Offline inspection of a copied APK normally emits no runtime event.

## Cleanup

Close inspection tools and retain only the team’s own APK copies and evidence.

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
