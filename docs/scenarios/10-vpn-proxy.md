# 10 — VPN and proxy detection

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

VPN must run inside Android; proxy configuration and traffic routing are separate.

[WireGuard Android client](https://www.wireguard.com/install/) plus a team-owned working VPN endpoint/config; Burp from case 08; ADB.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Without a VPN/proxy, sign in and save Lab device context.
2. Import the team’s lab WireGuard tunnel into the Android guest, activate it, and confirm the Android VPN indicator appears. Ensure tunnel routes allow access to the backend.
3. Refresh Lab context (`vpnTransport`) and Home. Enable the SDK VPN policy and repeat; record the VPN event/action.
4. Disable the VPN. For a proxy-configuration check, run `adb -s $Serial shell settings put global http_proxy WINDOWS_IP:8082` with your actual Windows IP.
5. Refresh Lab `httpProxy`, reopen the app and record the configured-proxy policy result. Do not assume that the Dart client now routes through it.
6. For actual proxied traffic, follow case 08 and confirm requests in Burp history. Keep VPN and proxy outcomes separate.

## Expected result and interpretation

Android VPN and proxy conditions trigger the corresponding configured policies without confusing them with backend connectivity.

A Windows-host VPN may not set Android VPN transport. A tunnel that breaks routing is not a detector pass. Air-gapped VPN testing needs a local endpoint, not a commercial cloud VPN.

## Cleanup

Disable the tunnel. Run `adb -s $Serial shell settings put global http_proxy :0`; verify context clears and direct HTTPS works.

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
