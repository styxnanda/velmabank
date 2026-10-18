# 08 — Anti-MiTM / trusted TLS interception

Status: **Not executed**. The current APK has no RASP SDK. Baseline TLS validation and vendor anti-MiTM detection are separate results.

## Tools and environment

- Windows: Burp Suite Community or Professional; manual Proxy features are sufficient. No Docker is required for the normal Burp path below.
- BlueStacks with Velma, and a backend reachable from Windows on TCP 8080.
- Windows `certutil` for converting the exported public Burp CA, if exported as DER.
- Complete [shared setup](00-shared-setup.md). Use only the lab endpoint and dummy accounts.

Burp is chosen here because its invisible listener can handle a client that does not use a system proxy. This setup deliberately changes Velma's configurable origin to the proxy, avoiding root/DNS edits; it demonstrates trusted interception, not transparent routing or DNS-spoof detection. The path is:

```text
Velma in BlueStacks --HTTPS--> Windows Burp :8082 --HTTP--> lab backend :8080
```

The backend's deliberate HTTP listener keeps upstream certificate setup out of this test. It is not an end-to-end HTTPS topology.

## Steps

1. Establish direct HTTPS baseline at `https://SERVER_IP:8443`, with the backend CA trusted. Sign in and refresh balance. Save that result before modifying the connection.
2. On Windows determine its guest-reachable IPv4 address using `ipconfig`. In Burp Proxy settings add a listener on TCP **8082**, bound to that lab interface (or all interfaces if necessary). Restrict its Windows Firewall inbound access to your lab. Do not reuse backend port 8080 on a PC running both.
3. In the listener's Request handling settings, enable **Support invisible proxying**, redirect host to `SERVER_IP`, and redirect port to `8080`. Leave **Force use of TLS** OFF for the backend HTTP leg. Confirm the destination is the backend, not the listener itself.
4. In listener certificate settings select **Generate a CA-signed certificate with a specific hostname**, using the exact Windows address/hostname the app will connect to. Turn Proxy Intercept OFF initially so requests do not appear to hang. See [PortSwigger listener settings](https://portswigger.net/burp/documentation/desktop/settings/tools/proxy) and [invisible proxying](https://portswigger.net/burp/documentation/desktop/tools/proxy/invisible).
5. In Velma change origin to `https://WINDOWS_IP:8082`. Keep the original backend CA in the app. Check connection. It should fail certificate validation because the Burp CA has not been trusted. Record this as the **baseline TLS negative control**, not a RASP pass.
6. Export the public Burp CA from Proxy certificate settings. If it is DER, convert on Windows:

   ```powershell
   certutil -encode .\burp-ca.der .\burp-ca.pem
   Get-Content .\burp-ca.pem
   ```

   Paste the full PEM into Velma's Connection settings, replacing the backend CA for this phase. No Android system-wide CA installation is needed because Velma accepts an explicit app-local lab CA.
7. Check connection, sign in, then refresh Home. In Burp HTTP history verify `/health`, `/auth/login` and `/me`. A login response containing a session token demonstrates that the baseline traffic actually traversed the proxy. Do not copy token/key values into this report.
8. If TLS still fails, check clock, guest routing, listener binding and certificate name. The leaf certificate must contain a SAN matching the exact app origin. Do not disable certificate validation. If your Burp version does not generate a suitable IP certificate, use the optional custom certificate path below or a guest-resolvable lab DNS hostname.
9. With the SDK-enabled APK, enable the vendor anti-MiTM policy, reproduce the **same trusted-interception condition**, and record the specific vendor event and action. Disable unrelated proxy/CA policies temporarily if they would mask the feature being measured, and record those overrides.
10. Return to direct backend HTTPS/CA and verify the clean control recovers. Compare untrusted TLS failure, trusted baseline interception, and SDK-enabled behavior as three separate rows of evidence.

## Optional deterministic IP certificate

If Docker is available on the Windows prep PC, the source includes:

```powershell
pwsh -File .\scripts\windows\New-BurpCertificate.ps1 -WindowsHost WINDOWS_IP
```

It uses the already loaded API image (no pulls) to generate an IP/hostname-valid certificate and `artifacts\burp-tls\burp-listener.p12`. Import that PKCS#12 as the listener's **custom certificate**, password `velma-lab`; use its `ca.crt` in the app for the trusted phase instead of Burp's CA. This optional helper is **not required** for the normal Burp-generated certificate route. Without local Docker, an operator on a Docker machine can generate equivalent certificates using the bundled `app.certificates` module and export PKCS#12 with the Python code in that script; transfer only this dedicated test certificate set.

## Expected result and limitations

The baseline rejects an untrusted certificate and permits explicitly trusted interception; no certificate pinning is implemented. After SDK integration, only a matching vendor event plus configured action counts as RASP enforcement. Some SDKs detect installed CAs or proxy settings rather than interception of Dart sockets; confirm the vendor's stated scope.

If Burp history is empty, the routing setup is incomplete—do not score the detector. If the listener stalls, turn Intercept OFF. If the backend is unreachable from Windows, fix that route before retesting.

## Cleanup

Restore `https://SERVER_IP:8443` and backend `ca.crt`; stop/remove the lab listener and temporary firewall rule. Sign out and protect/delete captures containing dummy credentials. Remove the optional test certificate folder when it is no longer needed.

## Report

| Field | Record |
|---|---|
| Operator / date / BlueStacks instance | |
| APK hash / SDK version / policy ID | |
| Burp version / listener and upstream addresses | |
| Direct HTTPS control | |
| Untrusted certificate control | |
| Trusted interception baseline + history evidence | |
| SDK event ID / timestamp / actual action | |
| Recovery after cleanup | |
| Result / limitation | not_tested |

[Scenario index](../RASP_POC_GUIDE.md)
