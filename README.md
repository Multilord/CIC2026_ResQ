# ResQ-Haul

Interactive demo of a food recovery and smart waste collection platform for Kuala Lumpur.

## Run the demo

Open `resq-haul/dist/index.html` in a browser, or serve it locally:

```sh
python -m http.server 4173 --directory resq-haul/dist
```

Then visit http://localhost:4173. No build step or application dependencies are required.

## Features

- Donation and sale listings with in-app demand matching
- Simulated recovery windows, traffic, temperature and pickup delays
- Capacity-aware recipient switching and handover confirmation
- Expiry cascade and physical bin-transfer confirmation
- Simulated smart-bin readings and collection routes
- Recovery totals, activity log and CSV export
- Responsive desktop/mobile views and browser-local demo persistence

All transactions, sensors, destinations and predictions are simulated. This prototype does not certify food safety or issue tax receipts.

See [the detailed project review and walkthrough](resq-haul/README.md) for demo instructions, modeling assumptions and production requirements. The source reference documents and private hosting configuration are not included in this repository.
