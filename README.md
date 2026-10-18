# Velma Bank

An Android Flutter banking sandbox with a self-contained Docker backend for RASP PoCs. **No RASP SDK is installed yet.** Every account, card, OTP and amount is fictional.

## Included

- Login/logout with expiring server sessions; two seeded users.
- Persistent balances, recipients, transfer preparation, lab OTP inbox, confirmation and activity history.
- Atomic transfers, owner checks, bounded OTP attempts and idempotent confirmation.
- Virtual card freeze/unfreeze stored by the backend.
- Lab workspace: Android context, signer identity, secure-window toggle, fresh location/mock flag, auto-clicker tap target, manual evidence and JSON export.
- Per-user/per-session AES-256-GCM encrypted round-trip probe.
- HTTPS with explicit private-CA trust and a deliberately opt-in HTTP mode.
- Baseline and visibly labeled clone Android flavors, plus a controlled post-build asset-patching/re-signing script.
- Portable amd64/arm64 Docker image export, offline certificate generation, persistent SQLite storage.
- [24-case RASP PoC guide](docs/RASP_POC_GUIDE.md), including Developer Options allowed / mock GPS blocked and auto-clicker versus blacklisting.

## Windows lab and delivery

Read [Windows prep](docs/WINDOWS_PREP.md) for prerequisites. Docker on Windows is optional: use the supplied archive, build with Docker Desktop, or trigger an online Linux Docker builder over SSH. The final ZIP includes APKs, backend images, source and [24 separate step-by-step reports](docs/RASP_POC_GUIDE.md).

## Run

See [deployment and BlueStacks instructions](docs/DEPLOYMENT.md). On an online preparation machine:

```sh
./scripts/make-certs.sh localhost
./scripts/package-offline.sh amd64
# Run locally after packaging (or transfer and run start-offline.sh on the target):
docker compose up -d --pull never --no-build
./scripts/build-android.sh
```

Install the baseline APK. Set the backend LAN origin in Connection settings, configure TLS using the guide, and log in with `alice` or `bob` / `VelmaDemo!2026`. Each starts with Rp 2,500,000. API amounts are integer minor units (100 = Rp 1). API docs: `http://SERVER_IP:8080/docs`.

The offline tarball includes all container layers; Docker Engine and Compose must already exist on the server. The final server IP can be configured offline. APKs and image archives stay in `artifacts/`, outside Git. Release APKs use a local lab/debug signing certificate until you provide a dedicated lab signing identity.

## Development and minimal checks

```sh
cd mobile
flutter pub get
flutter analyze
flutter test
# Requires a running backend; uses the same Dart API/encryption client as the app:
dart run tool/smoke.dart http://127.0.0.1:8080
```

[Architecture and intentional lab boundaries](docs/ARCHITECTURE.md) · [Verification record](docs/VERIFICATION.md)
