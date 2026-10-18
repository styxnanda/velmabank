# Velma Bank delivery — start here

This ZIP is for transfer to your Windows lab PC. It includes **three APKs, a prebuilt Linux amd64 backend archive, all guides, and the source ZIP**. No RASP SDK is integrated yet.

## On Windows

1. Extract this ZIP. Install `android/velma-baseline.apk` in BlueStacks using Install APK.
2. Decide how to prepare the backend:
   - **No Docker and no rebuild needed:** copy `backend/velmabank-offline-amd64.tar.gz` straight to the air-gapped Linux server. All image layers are already present.
   - **Rebuild locally:** extract `velmabank-source.zip`, install PowerShell 7 and Docker Desktop (Linux containers), then run `scripts/windows/Prepare-Backend.ps1` from that source directory.
   - **Rebuild without Docker on Windows:** extract the source, use PowerShell 7 plus Windows OpenSSH and `scripts/windows/Prepare-BackendRemote.ps1` to build on an online Linux Docker host and download the finished archive to Windows.
3. Follow [Windows prep](WINDOWS_PREP.md) for exact commands/prerequisites. A fresh image build requires a compatible engine somewhere; the supplied archive avoids that requirement on the prep PC entirely.
4. On Linux: extract the backend archive and run `bash start-offline.sh`. Docker Engine and Compose v2 must already be installed. Configure the final IP with `bash configure-tls.sh SERVER_IP --replace` and restart the TLS service.
5. In Velma set `https://SERVER_IP:8443`, paste the public backend `ca.crt`, and sign in as `alice` or `bob`, password `VelmaDemo!2026`.
6. Start with [shared BlueStacks setup](scenarios/00-shared-setup.md), then select an individual report from the [PoC index](RASP_POC_GUIDE.md).

## Files and boundaries

- `android/velma-baseline.apk`: main app.
- `android/velma-clone.apk`: separate package, can coexist with baseline.
- `android/velma-tampered.apk`: changed asset and different signer, same package as baseline; use a separate clean instance.
- `backend/velmabank-offline-amd64.tar.gz`: complete backend images/configuration and offline Linux start/certificate scripts.
- `velmabank-source.zip`: committed source, including Windows/local/remote preparation scripts. No developer toolchains, database or APK signing keys.
- `docs/`: deployment, Windows prerequisites, architecture, verification and 24 separate scenario reports.
- `SHA256SUMS`: checksums of delivery contents. An adjacent `.sha256` file supplied outside the ZIP verifies the ZIP itself.

The backend archive includes disposable TLS server key material. Keep your cloud upload private to the team and rotate certificates to the final server IP. Third-party test tools, their installers and vendor SDK fixtures are not bundled. The APKs are lab-signed and predate vendor SDK integration; regenerate all variants after adding the SDK.
