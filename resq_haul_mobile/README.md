# ResQ-Haul Flutter prototype

The active app uses account-based workspaces and a shared backend. Sender replaces Kitchen; Recipient, Driver / Hauler, Recovery Facility and Admin have separate permissions. The latest supplied navy/yellow logo has circular clipping.

## Start

From the repository root:

```sh
python server/app.py
```

The API runs at http://127.0.0.1:4175. First-start admin credentials are written to `server/data/admin-access.txt`, excluded from Git. Register Sender accounts in the app. Recipient, Driver and Facility accounts need verification in Admin → Manage.

## Prepared role accounts

The local API creates these verified role accounts. They all use password `ResQReady2026!`:

| Role | Email |
|---|---|
| Sender | `sender@resq.local` |
| Recipient | `recipient@resq.local` |
| Alternate recipient | `pantry@resq.local` |
| Driver / Hauler | `driver@resq.local` |
| Recovery Facility | `recovery@resq.local` |

Five prepared journeys cover a new listing, an accepted delayed delivery with a faster route, a five-minute expiry transition, a batch already diverted to recovery and a completed BSFL recovery. Admin can select **Restart journey timings** to refresh them without deleting other accounts or listings. Credentials are also written locally to `server/data/role-access.txt`.

In another terminal:

```sh
cd resq_haul_mobile
flutter pub get
flutter run -d chrome --web-port 4174 --dart-define=API_BASE_URL=http://127.0.0.1:4175
```

For a static browser preview:

```sh
flutter build web --release --no-web-resources-cdn
python -m http.server 4174 --bind 127.0.0.1 --directory build/web
```

## Android

For an emulator:

```sh
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:4175
flutter build apk --debug --dart-define=API_BASE_URL=http://10.0.2.2:4175
```

For a USB phone, use `adb reverse tcp:4175 tcp:4175` and `API_BASE_URL=http://127.0.0.1:4175`. Debug builds allow local HTTP. Release deployment requires HTTPS and signing. iOS source is included; compilation/signing require macOS and Xcode and have not been verified.

## Gemini

Copy `server/config.example` to `server/local.env`. Set `GEMINI_API_KEY` and `GEMINI_MODEL` locally and restart the API. Select a model available to your Google project supporting generateContent structured JSON. Do not put credentials into Flutter or Git.

The local timing and expiry rules work without Gemini. If configured, the worker reviews changed recoveries every 30 seconds, recommends capacity-eligible participants, evaluates driver-supplied alternative arrival estimates, applies validated same-recipient route changes and escalates unresolved risk. People still accept tasks and confirm physical handovers. Admin can pause coordination. No custom model training has been performed.

## Checks

```sh
python -m unittest discover -s server -v  # repository root
flutter analyze                         # mobile directory
flutter test
```

See [Flow and stack](docs/PROJECT_FLOW_AND_STACK.md) and [Verification](docs/VERIFICATION.md).

## Limits

Accounts, data, permissions, transitions and audit history are shared through the local API. The network starts with five prepared journeys. Sessions last 12 hours and stay in memory; reopening the app requires sign-in. The original offline walkthrough and tests remain for reference, but main.dart launches the new app.

Maps/GPS, route-provider ETAs, push notifications, IoT sensors, payments, email verification, password recovery and managed deployment are not connected. Participant-entered ETAs are estimates; recorded sale prices are not payments. Activity refreshes every 10 seconds. Gemini has not been live-tested without credentials. This local HTTP service is for a controlled pilot, not a public production deployment.
