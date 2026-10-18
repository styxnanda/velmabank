# Architecture and lab boundaries

Flutter Material 3 UI → Dart `HttpClient` → nginx HTTPS → FastAPI → SQLite named volume. Explicit HTTP connects directly to FastAPI. No cloud services or runtime internet dependencies. Android bridge supplies limited OS context and a future SDK callback seam. Only Android is generated.

## Contract

| Route | Purpose |
|---|---|
| GET /health | Public readiness marker |
| POST /auth/login | Username/password → token, expiry, user ID, session AES key |
| POST /auth/logout | Revoke current session |
| GET /me | Owner's account, balance and card state |
| GET /beneficiaries | Other seeded account |
| GET /transactions | Owner's latest 100 movements |
| POST /transfers | Prepare transfer and generated OTP |
| GET /lab/otp-inbox | Owner's active lab OTPs (intentional simulation) |
| POST /transfers/{id}/confirm | Owner-bound, atomic and idempotent confirmation |
| POST /card | Save demo card freeze state |
| POST /lab/encryption | Session-bound AES-GCM round trip |
| POST/GET /lab/events | Save/read operator-supplied observations |

All except health/login and OpenAPI documentation require bearer authentication. See `/docs` for field schemas. Passwords use salted scrypt. Random bearer tokens are hashed before storage; sessions expire after one hour. Invalid login attempts are limited by username (10 per five minutes), not a complete production abuse-control system. Transfer money is integer minor units; SQLite `BEGIN IMMEDIATE` serializes confirmation, and debit checks sufficient funds in the same transaction. Repeating confirmation cannot debit twice. Creating a new transfer after a lost create response can create another pending request; create is not idempotent. OTPs expire after five minutes with five failed attempts allowed.

## Intentional lab behavior

- Public fixed demo credentials; seeded balances; OTPs exposed only through the authenticated lab inbox.
- HTTP server and Android cleartext permission deliberately available, but the Dart client requires the HTTP lab toggle. Settings and sessions live in memory. Server-side session keys are plaintext within the lab DB; protect the server/volume.
- AES-GCM probe uses a 32-byte session key, random 12-byte nonce, user-bound AAD `velma:USER_ID`, ciphertext with appended 16-byte tag. TLS protects login key distribution. It is not a secure hardware key store, RASP encryption implementation, replay-protection protocol or encryption for all API traffic.
- No certificate pinning, root/emulator/keyboard/overlay blocking, or blanket Developer Options block. TLS validates certificates/hostnames, and redirects are rejected. The optional custom CA expands trust deliberately.
- Screenshot suppression is an explicit Android FLAG_SECURE control, OFF initially. It does not replace vendor overlay or remote-access detection.
- Location is foreground-only and requested on demand, with a fresh fix/12-second timeout. No background tracking, location upload, SMS access, call access, accessibility service, or unrestricted app enumeration is included.
- Baseline and clone have different package IDs and markers. Both are legitimate builds; clone is not a post-build tampered artifact. The backend never trusts a displayed client balance.
- Observations are operator evidence and may be spoofed by an authenticated lab user. They are not trustworthy attestation for production decisions.
- Evidence/transactions persist without automatic retention cleanup; use a disposable lab and reset deliberately when appropriate. No production compliance, recovery, payment, fraud or multi-node guarantees are claimed.

## Extension points

Add vendor SDK initialization and native enforcement where required. Keep the existing banking requests and controls stable for before/after comparison. Native `publishRaspEvent` can feed sanitized callbacks to Dart; save only non-secret evidence. Integrate actual SMS/call-specific fixtures separately if the vendor requires them. Never use the presence of Developer Options as a substitute for active mock-location detection.
