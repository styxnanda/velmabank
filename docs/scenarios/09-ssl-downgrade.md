# 09 — SSL stripping / plaintext downgrade

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks; app transport controls provide a quick downgrade-policy test.

Burp listener from case 08; PowerShell; Velma HTTP lab toggle. No sslstrip tool is needed for this minimal case.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Confirm a direct HTTPS login with the correct backend CA and HTTP lab transport OFF.
2. Set the app origin to `http://SERVER_IP:8080` while leaving HTTP lab transport OFF; Check backend connection should fail locally.
3. Enable HTTP lab transport and retry against the intentionally exposed backend HTTP endpoint. Baseline should connect; record that this was an explicit operator downgrade.
4. Enable the SDK plaintext/downgrade policy and repeat. Capture the vendor event and whether login is prevented.
5. For a redirect control, use the case-08 HTTPS listener with its test CA trusted. Turn Burp response interception on for a health request and replace the response with `HTTP/1.1 302 Found`, a `Location: http://SERVER_IP:8080/health` header, `Content-Length: 0`, and a blank line. The client should reject the redirect; check that no automatic plaintext follow-up appears.
6. Restore direct HTTPS and confirm normal connection.

## Expected result and interpretation

Baseline rejects HTTP unless opted in and never automatically follows a redirect. SDK enforcement of deliberately enabled plaintext must be accompanied by its own event.

This app starts from an explicit origin rather than browser links. Manual HTTP and a redirect rejection validate downgrade controls, not a successful transparent SSL-stripping attack. A generic 302/connection error is not RASP evidence.

## Cleanup

Remove response interception rules, turn HTTP lab transport OFF and restore the backend HTTPS origin/CA.

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
