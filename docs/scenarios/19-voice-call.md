# 19 — Voice call / social engineering alerts

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

Physical Android with test SIM; optional separate supported VoIP case.

Two team-controlled phones/numbers; Android Phone app; RASP call-state policy.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. On the Android test phone with no call active, sign in and prepare a small dummy transfer. Do not confirm yet.
2. Start a normal call with a teammate using the second phone and keep the call active.
3. Return to Velma, open Transfer and the lab OTP screen. Record the alert, confirmation restriction or configured SDK action.
4. End the call and repeat the same navigation; confirm that the restriction clears.
5. Only if the vendor explicitly supports VoIP call detection, repeat in its supported VoIP app and label that result separately.

## Expected result and interpretation

An active supported call triggers the intended alert/restriction, with the idle control remaining allowed.

BlueStacks lacks a faithful cellular call path. This test exercises call-state policy, not whether a conversation is fraudulent. Required SDK permissions must be integrated first.

## Cleanup

End the call; clear pending test transfers by letting their OTP expire or completing a deliberate dummy transfer.

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
