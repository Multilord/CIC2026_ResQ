# ResQ-Haul

Flutter prototype for surplus-food redistribution and organic resource recovery.

The active app has Sender, Recipient, Driver / Hauler, Recovery Facility and Admin accounts; a shared SQLite backend; recorded handovers; and a server-side Gemini integration. Navy/yellow branding uses the supplied logo with circular clipping.

## API Keys & Configuration

Before starting the server, you must provide a Gemini API key so the AI Coordinator can function:
1. Copy `server/config.example` to `server/local.env`
2. Open `server/local.env` and paste your Gemini API key:
   `GEMINI_API_KEY=AIzaSy...`
3. You can also change the default Gemini model using `GEMINI_MODEL`.

## Start

```sh
python server/app.py
```

In a second terminal:


```sh
cd resq_haul_mobile
flutter pub get
flutter run -d chrome --web-port 4174
```

First-start admin access is written to `server/data/admin-access.txt` and excluded from Git. Register other roles in the app, then verify partners through Admin → Manage.

- [Setup, Gemini and Android instructions](resq_haul_mobile/README.md)
- [Project flow and stack](resq_haul_mobile/docs/PROJECT_FLOW_AND_STACK.md)
- [Verification](resq_haul_mobile/docs/VERIFICATION.md)

Earlier HTML code remains in resq-haul/. The active entry point is resq_haul_mobile/lib/main.dart. This is a functional local prototype; live navigation, IoT, push messages, payments and production deployment remain separate integrations.
