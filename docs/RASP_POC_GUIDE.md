# Velma Bank RASP PoC workbook

## Scope and quick procedure

This is an Android-only lab application. No RASP SDK is integrated yet. Device diagnostics are context, **not detector verdicts**. Baseline controls intentionally allow screenshots, third-party keyboards, Developer Options, emulators and installed test apps. App-level TLS and AES-GCM are separate from vendor RASP features. All credentials, cards, money, OTPs and notes are fictional.

Use an isolated BlueStacks instance and your backend. Preserve a clean snapshot. Install the baseline APK, complete one login and one transfer, then add the SDK in a later phase. In the RASP console, permit emulator use for **all scenarios except the emulator test**; otherwise an emulator block will prevent meaningful testing of every other feature. Change one policy/condition at a time. Start with report-only mode if the vendor supports it, then enable the intended action. Restore the clean state after each case.

For each case: (1) run the clean control, (2) introduce the specified condition, (3) reopen the app and repeat the action, (4) capture the vendor event and actual app behavior, (5) restore the control. A generic app crash, TLS failure, OS restriction or failed APK install is not a RASP pass. Verify a corresponding vendor event and the configured action. Record vendor version/policy ID, app SHA-256 and signer, Android/BlueStacks version, expected action, observed result and timestamp. Most individual cases should take 5–10 minutes once tools/policies are installed.

Use Lab → Record PoC evidence. `pass` means the **intended policy** occurred, not necessarily that the app was blocked. `not_supported` is appropriate where the emulator/hardware cannot represent the condition. Copy loaded evidence as JSON or use authenticated `GET /lab/events` (latest 200 per user). Block-at-launch results must be recorded in this Markdown report or the vendor console because the app cannot open to log them. Manual app observations are not authenticated vendor telemetry.

## Individual step-by-step reports

Start with [Windows preparation and tool requirements](WINDOWS_PREP.md) and [shared BlueStacks setup](scenarios/00-shared-setup.md). Each case is a separate Markdown runbook/report with tools, steps, expected results, cleanup and fill-in evidence. Third-party tools are not included in the ZIP.

- [01 — Root / jailbroken-device detection](scenarios/01-root.md)
- [02 — Insecure configuration / ADB](scenarios/02-insecure-configuration.md)
- [03 — Emulator detection](scenarios/03-emulator.md)
- [04 — Anti-debugging](scenarios/04-debugging.md)
- [05 — Screen mirroring and overlays](scenarios/05-screen-overlay.md)
- [06 — Per-user / per-session encryption](scenarios/06-session-encryption.md)
- [07 — Insecure Wi-Fi](scenarios/07-insecure-wifi.md)
- [08 — Anti-MiTM / trusted TLS interception](scenarios/08-mitm.md)
- [09 — SSL stripping / plaintext downgrade](scenarios/09-ssl-downgrade.md)
- [10 — VPN and proxy detection](scenarios/10-vpn-proxy.md)
- [11 — Anti-reverse-engineering / static inspection](scenarios/11-reverse-engineering.md)
- [12 — Post-build app tampering](scenarios/12-tampering.md)
- [13 — Application blacklisting](scenarios/13-blacklisting.md)
- [14 — App spoofing / alternate identity](scenarios/14-spoofing.md)
- [15 — Untrusted / insecure keyboard](scenarios/15-keyboard.md)
- [16 — Spyware, riskware and adware](scenarios/16-malware-categories.md)
- [17 — Hooking framework detection](scenarios/17-hooking.md)
- [18 — Keylogger prevention / sensitive input](scenarios/18-keylogger.md)
- [19 — Voice call / social engineering alerts](scenarios/19-voice-call.md)
- [20 — SMS forwarding / OTP sharing](scenarios/20-sms-otp.md)
- [21 — Screen sharing / remote access](scenarios/21-remote-access.md)
- [22 — USB / juice-jacking risk signals](scenarios/22-usb.md)
- [23 — Auto-clicker detection versus application blacklisting](scenarios/23-auto-clicker.md)
- [24 — Developer Options allowed / mock location blocked](scenarios/24-mock-location.md)

## Fast execution order

1. Banking baseline, encryption, Developer Options-only allowance.
2. Blacklist, auto-clicker, keyboard, overlay and Android screen sharing.
3. VPN/proxy, HTTPS interception, deliberate HTTP lab transport.
4. Mock location, debugger, root/hook fixture, clone/tamper fixture.
5. Emulator blocking last (it may lock you out of all other tests).
6. Physical-device Wi-Fi, cellular call, real SMS and USB cases as a separate optional pass.

## Evidence template (copy for each case)

```markdown
### Case ID / feature
- Date / operator:
- App SHA-256 / package / signing certificate:
- Device / Android / BlueStacks version:
- SDK version / policy ID:
- Clean control:
- Condition introduced:
- Expected event + action:
- Actual app behavior:
- Vendor event ID / time:
- Screenshot/log reference (dummy data only):
- Result: baseline / pass / fail / blocked / not_supported
- Cleanup confirmed:
- Limitation / follow-up:
```

## Future integration handoff

Native bridge: `mobile/android/app/src/main/kotlin/com/velma/velma_bank/MainActivity.kt`, channel `com.velma.bank/lab`, method `raspEvent`. `publishRaspEvent` is a placeholder callback adapter; it is not called until a vendor SDK is wired in. Dart displays the sanitized callback as draft evidence; explicit Save records it. Integrate SDK initialization at the vendor-required Android lifecycle point (possibly an Application class before Flutter starts), permissions, Gradle dependencies, signing configuration, and configured enforcement. Do not rely on this Flutter evidence callback to enforce a launch-time security decision. Decide with the vendor which policies must execute natively before sensitive screens, which require server enforcement, and which work offline.

Before enabling mock-location policy, specify that Developer Options alone is permitted and active mock usage is the trigger. Before auto-clicker testing, define separate installed-package and active-automation policies. Preserve baseline APKs so SDK-enabled behavior can be compared with identical banking flows.

## Reference behavior

- [Flutter Android release packaging and signing](https://docs.flutter.dev/deployment/android)
- [Flutter HTTP transport policy caveats](https://docs.flutter.dev/release/breaking-changes/network-policy-ios-android)
- [Android Location.isMock](https://developer.android.com/reference/android/location/Location#isMock())
- [Android FLAG_SECURE](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)

These references describe platform behavior, not guarantees about your future RASP vendor.
