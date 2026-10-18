# 24 — Developer Options allowed / mock location blocked

Status: **Not executed**. This is a runbook and fill-in report; the shipped app has no RASP SDK yet.

## Tools and environment

BlueStacks if it exposes genuine Android mock-provider state; physical fallback.

[Fake GPS location by Lexa](https://play.google.com/store/apps/details?id=com.lexa.fakegps), or vendor-approved mock provider; Android Developer Options; Velma location probe.

Complete [shared Windows/BlueStacks setup](00-shared-setup.md) first. Use the SDK-enabled build for RASP verdicts, allow unrelated emulator/root/debug policies as needed, and record a clean baseline before changing one condition. Plan 5–10 minutes after prerequisites are ready.

## Steps

1. Set the policy explicitly: Developer Options allowed, active mock-location usage blocked/reported. Keep USB-debugging and emulator restrictions from masking this case.
2. Enable Developer Options, set Select mock location app to None, and stop any mock provider. Sign in; refresh Lab context and confirm Developer Options is true while the app stays usable.
3. Turn device Location on. Tap Read location / mock flag, grant foreground location permission and obtain a fresh control fix. Record `isMock`, provider and fix time.
4. Install the approved Fake GPS app. In Android Developer Options → Select mock location app, select it. In Fake GPS choose a harmless test coordinate and press its start/play control.
5. Return to Velma and request another fresh fix. Verify `isMock: true` before evaluating active mock policy; then capture the vendor event/action.
6. Stop Fake GPS and set the mock app back to None while keeping Developer Options ON. Obtain a fresh non-mock fix and confirm access returns.

## Expected result and interpretation

Developer Options alone remains allowed. Active mock usage produces its own event/action, and stopping mock usage clears it without disabling Developer Options.

BlueStacks location controls can synthesize coordinates without an Android mock flag. A timeout is inconclusive; an old/cached fix is not the control. Use a physical device if a fresh real/mock pair cannot be obtained.

## Cleanup

Stop/uninstall the provider, set mock app to None and keep the allowed Developer Options state for the final control.

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
