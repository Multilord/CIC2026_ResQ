# Verification — prototype overhaul

## Verified

- Flutter static analysis: no issues.
- Six new widget tests: circular logo/sign-in/registration and all five workspaces at 360–390 px phone widths.
- Fourteen existing offline workflow/layout tests remain as regression coverage; the first combined run passed those and exposed a registration dropdown overflow in the new UI. That overflow was fixed and the six new tests passed on rerun.
- Ten backend tests: delivery code validation, role and stale-version enforcement, expiry/custody, complete facility workflow, rejected loads, capacity/verification, same-recipient route priority, transfer acceptance, admin pause/audit, Gemini action validation, plus HTTP registration/login/authorization/logout.
- Web release build succeeded.
- Android debug APK version 3.0.0+3 built successfully; uses loopback API access with USB port forwarding.
- Headless Edge: actual admin sign-in against the local service, phone and desktop screenshots, no JavaScript page errors.
- The latest logo is circular in sign-in and workspace headers; the artwork and lettering are preserved.

## Not live-verified

- Gemini network calls: no credentials/model configured. Provider responses were mocked to verify server validation. Configuration is in server/config.example.
- Real GPS/maps, smart-bin hardware, payments or external push messaging: not connected.
- Android device installation and iOS compilation/signing: not tested on physical devices.

The SQLite service starts with an empty recovery network. Create accounts and listings to test shared operations. Admin bootstrap access is saved locally under server/data and never included in source archives or Git.
