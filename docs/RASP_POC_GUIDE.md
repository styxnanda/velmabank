# Velma Bank RASP PoC workbook

## Scope and quick procedure

This is an Android-only lab application. No RASP SDK is integrated yet. Device diagnostics are context, **not detector verdicts**. Baseline controls intentionally allow screenshots, third-party keyboards, Developer Options, emulators and installed test apps. App-level TLS and AES-GCM are separate from vendor RASP features. All credentials, cards, money, OTPs and notes are fictional.

Use an isolated BlueStacks instance and your backend. Preserve a clean snapshot. Install the baseline APK, complete one login and one transfer, then add the SDK in a later phase. In the RASP console, permit emulator use for **all scenarios except the emulator test**; otherwise an emulator block will prevent meaningful testing of every other feature. Change one policy/condition at a time. Start with report-only mode if the vendor supports it, then enable the intended action. Restore the clean state after each case.

For each case: (1) run the clean control, (2) introduce the specified condition, (3) reopen the app and repeat the action, (4) capture the vendor event and actual app behavior, (5) restore the control. A generic app crash, TLS failure, OS restriction or failed APK install is not a RASP pass. Verify a corresponding vendor event and the configured action. Record vendor version/policy ID, app SHA-256 and signer, Android/BlueStacks version, expected action, observed result and timestamp. Most individual cases should take 5–10 minutes once tools/policies are installed.

Use Lab → Record PoC evidence. `pass` means the **intended policy** occurred, not necessarily that the app was blocked. `not_supported` is appropriate where the emulator/hardware cannot represent the condition. Copy loaded evidence as JSON or use authenticated `GET /lab/events` (latest 200 per user). Block-at-launch results must be recorded in this Markdown report or the vendor console because the app cannot open to log them. Manual app observations are not authenticated vendor telemetry.

## Intermediate scenarios

| ID / feature | Simple setup and app action | Expected after SDK/policy integration | Control / limitation |
|---|---|---|---|
| 01 Root device (Android equivalent of jailbreak) | Use a team-controlled rooted Android fixture supported by the vendor; open app and attempt login. | Vendor root signal and configured block/report action. | Compare with unrooted fixture; do not assume every BlueStacks image is rooted. iOS jailbreak is out of scope. |
| 02 Insecure configuration | Enable ADB/USB debugging in a test instance; refresh Lab device context, then sign in. | The specific configured insecure setting is identified. | Turn it off and repeat. Developer Options alone stays allowed for case 24; avoid a blanket policy conflict. |
| 03 Emulator | Enable emulator blocking, then launch in BlueStacks. | Emulator event and configured launch block. | Use a physical Android device as negative control. Re-allow emulators before the other cases. |
| 04 Anti-debugging | Use the debug build and attach the normal Android debugger to your own process; repeat login. | Attached-debugger signal/action according to vendor support. | Detach and repeat; distinguish a debuggable build signal from an actually attached debugger. Release build is non-debuggable. |
| 05 Mirroring / overlay | On a lab device mirror the display with a trusted test tool; separately enable a benign floating overlay over the balance/transfer screen. | Relevant capture or overlay event/action, as configured. | Keep app's OS secure-window switch OFF when assessing RASP. Toggle it ON only as an independent OS control. Host-level BlueStacks window capture may be invisible to Android; do not grade that as an Android detector failure. |
| 06 Per-user / per-session encryption | Alice runs Lab encrypted round trip; sign out and sign in again; repeat as Bob. Inspect envelopes using your own lab traffic tooling. | App baseline uses distinct keys per login and authenticated encrypted payloads; separately verify vendor encryption scope after integration. | Existing AES-GCM covers only the encryption probe, not every banking endpoint. Keys are delivered at login over TLS and kept in memory; HTTP mode exposes them. GCM encryption alone does not provide replay protection. |
| 07 Insecure Wi-Fi | Connect a physical test device to a team-owned open Wi-Fi AP and refresh banking data. | Vendor insecure Wi-Fi alert/action. | Repeat on secured Wi-Fi. BlueStacks often sees virtual Ethernet/Wi-Fi unrelated to the host AP's security; physical device usually required. |
| 08 Anti-MiTM | Route test traffic through a team proxy; first use an untrusted certificate, then a test CA explicitly trusted by the app's Connection setting. Refresh balance. | Untrusted TLS already fails in baseline. With trusted interception, any additional block must match a RASP event/policy. | No certificate pinning is built in. Remove the test CA afterward. Dart HttpClient may not honor Android's system proxy; route traffic at a controlled gateway if needed. |
| 09 SSL stripping / downgrade | Clean control uses HTTPS. Attempt a redirect/downgrade via the lab gateway; separately choose HTTP with the explicit lab toggle and sign in. | Baseline rejects redirects and HTTP unless opted in; SDK should block/report deliberate plaintext if that policy is enabled. | Manual HTTP demonstrates a plaintext policy, not by itself a successful SSL-stripping attack. Do not label baseline TLS rejection as RASP detection. |
| 10 VPN / proxy | Enable a benign Android VPN in the guest, refresh context and balance; separately route through a proxy. | Vendor VPN and/or proxy events according to configured policy. | Disable and repeat. A VPN on the BlueStacks host may not appear as Android VPN transport. Proxy configuration and actual interception are different observations. |
| 11 Reverse engineering | Inspect your APK with normal APK inspection tools; after SDK integration compare readability/obfuscation and the vendor's stated anti-analysis protections. | Static protection matches documented SDK capabilities; runtime response only if a supported runtime condition is introduced. | Merely inspecting a copied APK offline cannot normally emit an event to the running app. Flutter release AOT alone is not RASP protection. |
| 12 Tampered app | Preserve the original APK/hash. Run `scripts/make-tampered-apk.sh` to patch the harmless asset marker and re-sign a copy (or use a vendor fixture); install in a clean snapshot and launch. | Integrity/signer mismatch event and configured action, if installation succeeds. | Random byte changes usually break signatures or APK structure before launch. The provided clone and same-package rebuilt marker are controls, not a true post-build patch. No backend balance is trusted from client display values. |
| 13 App blacklisting | Add the exact package ID of a benign test app to the vendor blacklist; install that app, then launch Velma. | Velma blocks or reports as configured. | Uninstall it and repeat. SDK package visibility and Android permissions determine discovery; Velma does not request unrestricted package inventory. |
| 14 App spoofing | Install Velma Bank Clone alongside the original. Compare package IDs, labels and signer hashes in Lab; enroll only baseline identity if SDK supports app identity validation. | Clone identity fails the configured identity policy after proper SDK configuration. | Spoofing imitates identity/appearance; tampering changes an existing artifact. They overlap but need distinct expectations. Clone currently shares the lab signing key. |
| 15 Untrusted keyboard | Select a team-approved alternative keyboard and type only dummy credentials/notes. | Vendor untrusted-keyboard policy triggers where supported. | Return to the permitted keyboard. A non-default keyboard is not automatically malicious; define an allowlist/denylist. |
| 16 Spyware / riskware / adware | Use vendor-provided safe test packages/signatures, or blacklist a benign fixture as a policy control. Launch app. | The relevant vendor threat category/action appears for its supported fixture. | A benign blacklist fixture validates blacklist policy only, not malware classification. Do not deploy live malware; mark unavailable category fixtures not tested. |
| 17 Hooking framework | Use the vendor's known-safe rooted/hooking test image with its test framework installed/active; launch and perform a transfer. | Installed/active hooking signal as specified by vendor. | Compare clean image. Installed framework detection and active runtime hook detection are separate claims; no credential interception script is supplied. |
| 18 Keylogger prevention | Enable a benign vendor accessibility/keyboard test fixture and type dummy notes. | Vendor event and configured sensitive-entry restriction. | Disable fixture and repeat. Do not infer actual exfiltration prevention from an app-install blacklist alone. |
| 19 Voice call / social engineering | On a physical Android test device, start a call with a teammate, then open transfer and OTP screens. | Call warning or transaction restriction according to policy. | End call and repeat. BlueStacks does not faithfully simulate cellular call state; VoIP may require a separate supported detection path. No real calls/SMS are initiated by Velma. |
| 20 SMS forwarders / OTP sharing | Use a benign vendor forwarder test app or blacklist fixture. Exercise the lab OTP inbox and confirmation screen while it is installed/enabled. | Installation/behavior policy matches the supported fixture. | The inbox is in-app simulation, **not Android SMS**. Actual SMS forwarding/content detection requires a real test SIM, SMS delivery and an SDK-supported fixture outside this app. Never use real banking OTPs. |
| 21 Screen sharing / remote access | Start an Android guest screen-sharing session with a trusted tool; navigate to card and transfer screens. | Vendor remote-access/capture event and configured restriction. | Stop the session and repeat. Host desktop capture of BlueStacks may be outside guest visibility; prefer a physical device/Android MediaProjection path. |
| 22 USB / juice-jacking | Connect a physical Android device to a trusted lab workstation; compare charge-only with USB data/ADB mode while app is open. | Supported USB-risk signal/action, if the SDK advertises it. | USB attachment or ADB is a proxy condition, not proof of malicious charging-station detection. BlueStacks cannot faithfully test a physical USB power/data path. No hostile USB hardware required. |
| 23 Auto clicker + application blacklisting | First install a benign auto-clicker and blacklist its exact package; launch Velma. Separately allow installation, enable its automation/accessibility service, and target Lab's tap counter. | First test proves package blocking. Second should identify active automation if vendor supports behavioral detection. | Disable service, then uninstall and repeat. Tap count alone is not detection; do not treat package detection as proof of automated-input detection. Use the harmless tap target, not repeated payments. |
| 24 Developer Options allowed / mock GPS blocked | Configure policy to allow Developer Options. Enable it without mock provider, sign in and read a fresh location. Then select a benign mock-location app, start a simulated fix, and repeat Read location / mock flag. | Clean Developer Options case stays allowed; active mock location is blocked/reported independently. | `developerOptionsEnabled` and fresh location `isMock` are separate context fields. Merely selecting a provider does not prove active mock use. BlueStacks coordinates may be synthesized without an Android mock flag; verify fixture behavior and use physical device if ambiguous. Turn off mock provider afterward. |

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
