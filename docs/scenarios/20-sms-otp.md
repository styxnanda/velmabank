# 20 — SMS forwarding / OTP sharing

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks for package policy; physical test SIM and fixture for real SMS behavior.

Velma lab OTP inbox; vendor harmless SMS-forwarder fixture; for real SMS, two test phones/SIMs and a vendor-supported local receiver.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. For the BlueStacks subset, install the approved forwarder fixture and blacklist its exact package or enable the vendor’s supported forwarder policy.
2. In Velma prepare a dummy transfer, open Lab OTP inbox and enter the matching OTP. Record the installed-app policy result.
3. Remove the fixture and repeat. Label these results “package/forwarder fixture policy; simulated in-app OTP.”
4. For actual SMS testing on a physical device, use a teammate’s test phone to send only `VELMA TEST OTP 123456` to the test SIM. Configure the fixture to its documented team-controlled recipient.
5. With the SDK-enabled app foregrounded, observe the vendor forwarding/sharing event and action. Compare with the fixture service disabled.
6. Record whether real SMS was delivered/forwarded independently of Velma’s synthetic inbox.

## Expected result and interpretation

The relevant installed-package or real SMS/forwarding policy triggers only for its intended condition.

Velma sends no Android SMS and cannot validate real OTP-forwarding prevention alone. Copying its in-app code is not evidence of SMS interception. Do not claim the real-SMS result without the physical fixture.

## Cleanup

Disable/remove the forwarder, revoke test SMS permissions, and delete synthetic messages from the test phones.

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
