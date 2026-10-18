# 06 — Per-user / per-session encryption

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks; optional trusted Burp interception for inspecting lab envelopes.

Velma Lab encryption probe; Burp Suite Community/Professional configured using case 08; Burp Repeater for the cross-session negative test.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Complete case 08 trusted-interception baseline with RASP network blocking temporarily disabled so encryption can be observed independently.
2. Sign in as Alice. Run Lab → Encrypt → server → decrypt twice with the same dummy note. Save the two `/lab/encryption` envelopes; nonces/ciphertext should differ and both verified responses should echo the note.
3. Sign out and log in as Alice again. Observe that login returns a fresh session key/token. Compare only within the private lab capture; do not paste keys into the report.
4. Sign out; sign in as Bob. Save one new encrypted round trip and confirm it returns Bob’s user ID.
5. In Burp Repeater resend an Alice encryption envelope with Bob’s current Bearer token. Expect HTTP 400. Do not resend a transfer endpoint for this check.
6. After RASP integration, run the vendor encryption probe/telemetry separately and record what data its SDK protects.

## Expected result and interpretation

App AES-GCM round trips succeed in the correct session and fail under another session key. Vendor encryption claims require separate vendor evidence.

Only the probe is AES-GCM encrypted by this app. Login exposes the key to a deliberately trusted TLS interceptor, so this is not protection against a trusted MiTM. Different ciphertext alone does not prove distinct keys; GCM is not replay protection.

## Cleanup

Sign out; restore direct HTTPS and backend CA. Remove or protect captures containing dummy session keys/tokens.

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
