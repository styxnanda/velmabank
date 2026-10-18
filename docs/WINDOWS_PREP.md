# Windows lab preparation: tools and exact paths

The lab uses **BlueStacks on Windows** and a **Linux air-gapped Docker server**. The online preparation and BlueStacks host can be the same Windows PC. Choose one preparation path below; Docker Desktop is **not mandatory on Windows** if you use the supplied images or a remote builder.

## Choose your path

| Path | Installed on Windows | Where image is built | Best use |
|---|---|---|---|
| A — use supplied archive | ZIP extraction (Explorer); BlueStacks for the app | Already built and exported | Fastest first PoC; no rebuild needed |
| B — build locally | PowerShell 7+, Docker Desktop with Linux containers, Windows `tar.exe` | Docker's Linux VM on Windows | You want to rebuild on this PC |
| C — build over SSH | PowerShell 7+, Windows OpenSSH client (`ssh`/`scp`), `tar.exe` | Online Linux machine with Docker Engine, Compose v2, Buildx, bash, tar, gzip and sha256sum | No Docker on Windows, but an online builder is available |

Git for Windows is useful to clone/update the repository; it is not needed to run backend scripts from the included source ZIP. Flutter, Java, Android Studio/SDK, Python and OpenSSL are **not needed for backend preparation** on Windows. The container provides Python and cryptography. A compatible container engine must exist somewhere to build a Docker image; PowerShell alone cannot build one. WSL2 with Docker Engine is another local-engine arrangement, but these instructions use Docker Desktop for the local path.

The **air-gapped server** needs Linux, Docker Engine and Compose v2 already installed, plus bash/tar/gzip and sha256sum (or shasum). The image archives include all application layers and packages, not Docker/OS installers. Match the server CPU: `amd64` for Intel/AMD x86-64, `arm64` for ARM64. Default is amd64.

## Open the delivery ZIP on Windows

1. Extract `velmabank-delivery.zip` in Explorer, for example to `C:\VelmaLab`.
2. In the resulting `velmabank-delivery` folder, read `START_HERE.md`.
3. `android` contains baseline, clone and modified APKs. Install baseline using BlueStacks' Install APK button. Do not install the differently signed modified APK over baseline.
4. `backend\velmabank-offline-amd64.tar.gz` is already ready to transfer. For path A, skip directly to the Linux server steps below. You do not need Docker on Windows to copy this file.
5. For paths B/C, extract `velmabank-source.zip` into a `source` subfolder. Open PowerShell 7 (`pwsh`) in that source folder. It contains `backend`, `scripts`, `docs`, `mobile`, and `compose.yaml`.

## Path B — build on the Windows PC

1. Install [PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows) and [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/). Follow Docker's current supported Windows/WSL2 requirements and enable hardware virtualization. Use **Linux containers**. BlueStacks must use a configuration compatible with your virtualization setup; verify both applications start before building. See [BlueStacks Hyper-V guidance](https://support.bluestacks.com/hc/en-us/articles/4415238471053-System-requirements-for-BlueStacks-5-on-Hyper-V-enabled-Windows-10-and-11).
2. Start Docker Desktop and wait for the engine to be ready. In PowerShell 7 run:

   ```powershell
   $PSVersionTable.PSVersion
   docker version
   docker info --format '{{.OSType}}'
   docker compose version
   docker buildx version
   tar --version
   ```

   `OSType` must say `linux`. Use a current Docker Desktop supporting `docker save --platform` (Docker API 1.48+).
3. From the extracted source folder, run:

   ```powershell
   pwsh -File .\scripts\windows\Prepare-Backend.ps1 -Architecture amd64 -ServerHost localhost
   ```

   Leave `localhost` when the final IP is unknown. This downloads/builds the images, generates temporary lab certificates **inside the API image**, exports all layers, writes checksums, and creates `artifacts\velmabank-offline-amd64.tar.gz`. There is no PowerShell binary-pipeline dependency.
4. If Windows marks an extracted script as internet-downloaded, review it and use `Unblock-File` on that specific script. Do not change machine-wide execution policy. Organizational execution policy may require your administrator's normal process.
5. Copy the resulting `.tar.gz` to the air-gapped server. Existing export directories are not silently overwritten; move a previous `artifacts\velmabank-offline-amd64` aside before rerunning.

## Path C — no Docker on Windows; rebuild over SSH

1. Install PowerShell 7 and enable the Windows [OpenSSH Client optional feature](https://learn.microsoft.com/windows-server/administration/openssh/openssh_install_firstuse). Verify `ssh -V`, `scp`, and `tar --version` are available.
2. Arrange an **online Linux builder** with Docker Engine, Compose v2 and Buildx. Its SSH user must be able to run Docker without an interactive sudo prompt; the builder needs access to container registries/Python package downloads. Confirm its SSH host fingerprint through your normal process and sign in once:

   ```powershell
   ssh builderuser@builder-host
   ```

3. Back on Windows, in the extracted source folder run:

   ```powershell
   pwsh -File .\scripts\windows\Prepare-BackendRemote.ps1 -Builder builderuser@builder-host -Architecture amd64 -ServerHost localhost
   ```

4. The script uploads only backend-related source files, invokes the Linux builder and downloads `artifacts\velmabank-offline-amd64.tar.gz` to Windows. **Windows orchestrates the build; Linux performs it.** No Docker, Java, Flutter, OpenSSL or Python is required on Windows.
5. Transfer that archive to the air-gapped server. The remote temporary working directory is printed for your later cleanup; it contains lab TLS material. Custom SSH ports/jump hosts can be set through your usual SSH config using a host alias.

If you have neither a local container engine nor an online Linux builder, use path A. You cannot freshly build a Docker image with only the Windows shell.

## Start on the air-gapped Linux server

```sh
tar -xzf velmabank-offline-amd64.tar.gz
cd velmabank-offline-amd64
bash start-offline.sh
# Replace this example with the final LAN IP, once known:
bash configure-tls.sh 192.168.10.50 --replace
docker compose restart tls
docker compose ps
```

Use `bash` explicitly because Windows-produced archives may not preserve executable bits. Both `images.tar` (PowerShell exporter) and `images.tar.gz` (Linux/macOS exporter) are supported. The start script verifies checksums, checks architecture, loads images and runs Compose with no pulls/builds. After intentional certificate rotation, restart with `docker compose up -d --pull never --no-build`; the original checksums describe the pre-rotation certificate set.

Allow lab traffic from BlueStacks to server TCP 8443 (HTTPS), and 8080 only for intentional plaintext cases. In Velma Connection settings use `https://SERVER_IP:8443`, and paste the **public** `deploy/certs/ca.crt`. `localhost` inside BlueStacks means the guest, not the server or Windows host. See [shared setup](scenarios/00-shared-setup.md).

## Tools only if rebuilding Android

Use the supplied APKs initially. To rebuild after adding the RASP SDK: Flutter 3.47.4/Dart 3.13.3, Java 17+, Android SDK/platform/build-tools 36 and Flutter's matching NDK. Android Studio is the simplest SDK/debugger installer. Run `flutter doctor` and finish SDK/license setup, then:

```powershell
pwsh -File .\scripts\windows\Build-Android.ps1 -IncludeDebug
```

The debug APK is optional and only needed for case 04. The supplied modified APK is tied to the original baseline: regenerate it after SDK changes. Its current Bash generation script requires Git Bash, Python 3 and Java/Android build-tools on Windows, or run it on a Linux/macOS Android build machine. Baseline/clone release builds use the machine's local debug signing key; enroll the correct signer in the RASP console.

## Recreate a single delivery ZIP

From a clean committed Git checkout, with the three matching APKs in `artifacts\android` and a prepared backend tarball:

```powershell
pwsh -File .\scripts\windows\New-Delivery.ps1 -Architecture amd64
```

This writes `artifacts\velmabank-delivery.zip` and its SHA-256 sidecar, containing APKs, backend archive, docs and committed source. It excludes local build caches, databases, private APK signing keys and tooling. The backend archive **does include a disposable server TLS key**; keep the uploaded ZIP private to your team and rotate that certificate for the final server IP.
