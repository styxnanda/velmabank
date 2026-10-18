# Shared Windows / BlueStacks setup

Read [Windows preparation](../WINDOWS_PREP.md) first. **No Docker is needed on Windows just to install/test APKs or copy the supplied backend image.** Docker is needed on a local or remote builder only if rebuilding. Tools mentioned below are installed separately; third-party installers/APKs are not bundled.

## Establish one clean working control

1. Use a 64-bit BlueStacks Android instance compatible with the RASP SDK's supported Android version. Keep a separate instance/backup for modified APKs. See [BlueStacks ADB instructions](https://support.bluestacks.com/hc/en-us/articles/23925869130381-How-to-enable-Android-Debug-Bridge-on-BlueStacks-5).
2. Install `android\velma-baseline.apk` using Install APK. Install no other test fixtures yet. The supplied APK has no RASP SDK; it establishes baseline behavior only.
3. Deploy backend to the Linux server using `bash start-offline.sh`; generate a certificate for its final address. On Windows check:

   ```powershell
   Test-NetConnection SERVER_IP -Port 8443
   Test-NetConnection SERVER_IP -Port 8080
   ```

   Replace every uppercase placeholder. The app must reach the server from the Android guest too. If the backend runs on this Windows PC temporarily, use its reachable LAN IPv4 address and scope Windows Firewall rules to the lab. Never assume the Windows host is `10.0.2.2` in BlueStacks.
4. In Velma Connection settings enter `https://SERVER_IP:8443` and paste the full public `ca.crt` PEM; leave HTTP lab transport OFF. Check backend connection.
5. Sign in as `alice` / `VelmaDemo!2026`. Send Rp 10,000 to Bob, open the lab OTP inbox, enter the OTP matching the displayed transfer reference and confirm. Verify Activity; sign out and confirm Bob's receipt. See the deployment guide for balance units.
6. Before RASP tests, install the SDK-enabled build and configure its console. Keep emulator/root/debug policies from masking unrelated cases. Vendor cloud console requirements may need a connected test segment or an offline-capable policy; check with the vendor. The backend itself needs no internet.

## Optional ADB on Windows

Install [Google SDK Platform-Tools](https://developer.android.com/tools/releases/platform-tools), extract them, and add the directory containing `adb.exe` to PATH. BlueStacks' built-in ADB is another option, but use one tool version consistently.

1. Enable ADB in BlueStacks Settings → Advanced. Read the actual endpoint/port for that instance; ports vary.
2. Open PowerShell. For example, **only if** BlueStacks shows port 5555:

   ```powershell
   $Serial = '127.0.0.1:5555' # Replace with your instance's actual endpoint.
   adb connect $Serial
   adb devices -l
   adb -s $Serial shell getprop ro.build.version.release
   adb -s $Serial shell getprop ro.product.cpu.abi
   ```

3. All report commands using `$Serial` assume that variable was set in the current PowerShell window. Select the correct serial when multiple instances/devices exist. If USB debugging must be OFF in a case, use the app UI instead of trying to keep ADB attached.
4. To reopen baseline explicitly:

   ```powershell
   adb -s $Serial shell am force-stop com.velma.velma_bank
   adb -s $Serial shell am start -n com.velma.velma_bank/.MainActivity
   ```

## Evidence common to every report

```powershell
New-Item -ItemType Directory -Force .\evidence
Get-FileHash .\android\velma-baseline.apk -Algorithm SHA256
# Android screenshot via a file avoids PowerShell binary-redirection corruption:
adb -s $Serial shell screencap -p /sdcard/velma-evidence.png
adb -s $Serial pull /sdcard/velma-evidence.png .\evidence\
adb -s $Serial shell rm /sdcard/velma-evidence.png
```

Use the vendor console event ID/time and a screenshot of actual behavior. If capture is blocked, capture the external console or record the outcome manually. Optional `adb -s $Serial logcat -d` is supporting evidence, not guaranteed SDK telemetry. Store only dummy data; Burp traces can include demo passwords and session keys.

Each report starts as **not_tested**, not pass. Fill the table at its end. A crash, failed APK installation, lost route, generic TLS error, or enabled OS control alone is not a RASP detection pass. Restore the clean state after every case. App Lab evidence is operator-supplied, not trusted attestation.

## Tools by need

| Tool | Install when |
|---|---|
| BlueStacks | All guest app cases |
| Platform-Tools / ADB | Device context, installs, controlled restart/evidence |
| Burp Community or Professional | Cases 06/08/09/10 only; manual proxy features suffice |
| scrcpy | Android capture/control in 05/21 |
| Android Studio debugger | Case 04 |
| JADX / APK Analyzer | Case 11 |
| WireGuard + local test endpoint | VPN subcase 10 |
| Benign auto-clicker | Cases 05/23 |
| Fake GPS mock provider | Case 24 |
| Vendor safe fixtures | Root/hook setup and malware/keylogger/SMS categories as noted |
| Physical Android phone | Wi-Fi, calls, actual SMS and USB, plus ambiguous emulator cases |

Tool references are in the individual reports. Their menu names may change; record installed versions.
