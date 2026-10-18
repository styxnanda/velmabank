# 15 — Untrusted / insecure keyboard

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks or physical Android with an alternate IME.

Android keyboard settings; a team-approved alternate keyboard APK; SDK IME allowlist/denylist. Use a vendor fixture if no alternate keyboard is approved.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Record the original keyboard from Lab `defaultKeyboard` and confirm sign-in.
2. Install the approved alternate IME. Enable it in Android Settings → System → Languages & input → On-screen keyboard (labels vary).
3. Select the alternate as the active input method. Refresh Lab context and record its exact component/package.
4. Configure the SDK to flag that IME, then open login, Payment note and OTP fields. Type only dummy values; record the warning/block and SDK event.
5. Switch back to the original approved keyboard and repeat.

## Expected result and interpretation

The policy distinguishes the active untrusted IME from the approved control and applies the configured action.

An installed but inactive IME is a different condition. Third-party keyboards are not inherently malicious. No keyboard fixture is bundled; record not tested until you have an approved one.

## Cleanup

Restore the original input method, disable/uninstall the test IME and clear its temporary policy.

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
