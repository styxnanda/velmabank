# Deploy Velma Bank

## What you need

The target server needs Linux, Docker Engine and the Compose v2 plugin **already installed**. The image bundle contains the API, Python packages, nginx, and all image layers. It does not install Docker itself or provide an offline OS package repository. Default bundle architecture is `linux/amd64` (typical Intel/AMD server). Build a separate `arm64` bundle for ARM servers. APKs run on Android; backend containers run on the Linux server, not BlueStacks.

## Prepare while online

From repository root:

```sh
# An unknown final IP is fine: start with localhost and rotate offline later.
./scripts/make-certs.sh localhost
./scripts/package-offline.sh amd64
./scripts/build-android.sh
```

Transfer `artifacts/velmabank-offline-amd64.tar.gz` and the APKs in `artifacts/android/` to your test environment. Keep TLS private keys inside your team; they are excluded from Git. `images.tar.gz` contains both images, and SHA256SUMS verifies transferred files. The build requires internet; running the resulting bundle does not. Store the generated bundle for repeatability: rebuilding later may resolve newer base-image/dependency layers.

## Start with no internet

```sh
tar -xzf velmabank-offline-amd64.tar.gz
cd velmabank-offline-amd64
./start-offline.sh
# Once the final IP is known (example only):
./configure-tls.sh 192.168.10.50 --replace
docker compose restart tls
docker compose ps
```

`start-offline.sh` checks hashes and architecture, loads both images, and uses `--pull never --no-build`. There are no runtime package downloads, telemetry, email/SMS gateways, or external API dependencies. Generating certificates uses Python/cryptography from the loaded API image, without OpenSSL or internet on the host. The initial certificates support localhost/127.0.0.1/10.0.2.2; rotate them for the actual LAN address. The recorded SHA256SUMS describes the **original** bundle; after intentional certificate rotation, use `docker compose up -d --pull never --no-build` for restarts instead of rerunning the original checksum verifier.

Ports: TCP 8080 (explicit HTTP lab), TCP 8443 (HTTPS). Allow these from the BlueStacks host on your lab network. `VELMA_BIND=127.0.0.1` binds locally if needed; the default is all interfaces for remote-device access. TLS termination is in nginx; API-to-nginx traffic stays on the Docker network. The HTTP endpoint deliberately remains reachable to exercise downgrade scenarios; restrict it when evaluating an HTTPS-only policy.

## Connect from BlueStacks

1. Install `velma-baseline.apk` using BlueStacks APK install or `adb install velma-baseline.apk` against your own configured BlueStacks ADB endpoint. Universal release APKs include ARMv7, ARM64 and x86-64. Use a 64-bit BlueStacks Android instance if its ABI does not support these.
2. In the app, open the connection icon. Enter `https://SERVER_IP:8443` (not `localhost` or the Android-emulator-only default `10.0.2.2`). Paste the **public** `deploy/certs/ca.crt` PEM into the CA field. Never paste `server.key`.
3. Save and use **Check backend connection**. If needed, first confirm `http://SERVER_IP:8080/health` in a browser on the BlueStacks machine.
4. Sign in as `alice` or `bob`, password `VelmaDemo!2026`.
5. Alice starts with Rp 2,500,000. Send Rp 10,000 to Bob, open the lab OTP inbox, enter the matching six-digit OTP and confirm. Alice's balance falls, Bob's rises; both have activity entries.
6. Freeze/unfreeze the demo card. In Lab, run the encrypted round trip and record a baseline observation.
7. Sign out, sign in as Bob, verify receipt. Sign out invalidates the current token on the server when reachable; local credentials are cleared even if the server is unavailable. Failed remote logout leaves the old server token valid until its one-hour expiry.

Connection settings and credentials are memory-only. Re-enter the server/CA after a process restart. This intentionally avoids persistent token/key storage before SDK integration. Password text fields are prefilled with **public demo credentials**. No real SMS is sent; the authenticated lab inbox exposes the OTP deliberately.

## Operations

```sh
docker compose logs --tail=100
docker compose stop
docker compose up -d --pull never --no-build
# Back up with the API stopped, to avoid copying a live SQLite database:
docker compose stop api
docker compose cp api:/data/velma.db ./velma-backup.db
docker compose start api
```

SQLite lives in the `bank-data` named volume. `docker compose down` preserves it. To deliberately reset all demo balances, sessions and observations, use `docker compose down -v`, then start again. Do not do that if you need the evidence.

## Build Android

Flutter 3.47.4 / Dart 3.13.3 was used. Install Java 17+, Android SDK platform 36 and build tools; Flutter may install its matching NDK/compile SDK. `scripts/build-android.sh` produces baseline and clone release APKs. The target SDK is explicitly 36 so Android 17's new local-network permission model is not introduced accidentally into this PoC. Min SDK follows the installed Flutter toolchain.

Release builds currently use the **local debug signing key**, matching Flutter's generated project. They are non-debuggable but not production-signed. Preserve a consistent lab keystore before enrolling a signer allowlist in the RASP console. Build machines generate different debug certificates; an update signed by a different key needs uninstall/reinstall. Never commit private signing keys. The clone shares that signing identity by default but changes package ID and build marker; it is not proof of malicious tamper detection.

For debugging tests:

```sh
cd mobile
flutter build apk --debug --flavor baseline
```

For a changed-code fixture with the **same** package, build baseline with `--dart-define=BUILD_MARKER=modified-same-package-v1`, after preserving the original APK. This is a legitimate rebuild control, not a patched APK. Use the RASP vendor's sanctioned repackaging fixture when evaluating true post-build tampering. Random byte edits often invalidate ZIP/signature structures and fail to install before RASP can run.

## Controlled post-build tamper fixture

After building the baseline, run `./scripts/make-tampered-apk.sh` with `ANDROID_HOME` and Java/keytool available. It changes the bytes of the bundled `integrity_marker.txt` asset, re-aligns the APK, and signs it with a separate **test-only** key. The app's Lab panel displays this asset marker. Output: `artifacts/android/velma-tampered.apk`. This does not change balances, bypass RASP, or contain a hook. It is a valid, installable repackaging fixture with the **same package ID** and a different signer. Use a separate clean BlueStacks instance or uninstall baseline first (which removes local app data); it cannot update a differently signed installed app. With no RASP SDK, it should run normally. After SDK integration, rebuild baseline and regenerate the fixture to test the vendor's integrity/signer policy. The baseline remains untouched. The side-by-side clone is a separate spoofing fixture.
