# 23 — Auto-clicker detection versus application blacklisting

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks Android guest, not a Windows mouse macro.

[Auto Clicker – Automatic tap, True Developers Studio](https://play.google.com/store/apps/developer?id=True+Developers+Studio) or vendor-approved equivalent; Android Accessibility settings; Velma Lab tap target.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Install the approved auto-clicker from its official listing; record its actual package ID with `adb -s $Serial shell pm list packages`. Keep its Accessibility service OFF.
2. Subcase A: blacklist that exact package in the RASP policy, reopen Velma and record the installed-package block. Uninstall the clicker and verify recovery.
3. Subcase B: remove the blacklist rule, reinstall the clicker and keep its service disabled. Confirm Velma opens.
4. Enable the clicker’s Accessibility/overlay permissions, choose a single tap target, and position it over Lab → Auto-clicker target only.
5. Run approximately one tap per second for ten seconds. Record the counter and SDK event/action; never target a payment or OTP confirmation button.
6. Stop automation while leaving the app installed, then disable its service. Repeat the control to separate installed-package, enabled-service and active-automation results.

## Expected result and interpretation

Subcase A proves package blacklist policy. Subcase B proves active-automation detection only if the vendor emits evidence distinguishing active input from service/package presence.

Counter increments alone are not detection. A Windows auto-clicker may generate ordinary host mouse input invisible to an Android detector. Record vendor feature scope precisely.

## Cleanup

Stop automation, revoke Accessibility/overlay permissions, uninstall the clicker and clear temporary blacklist rules.

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
