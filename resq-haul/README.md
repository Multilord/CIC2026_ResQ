# ResQ-Haul demo

An interactive, responsive prototype of the food recovery and smart waste ecosystem. Open `dist/index.html` directly, or run `python -m http.server 4173 --directory dist` from this directory and visit http://localhost:4173.

## What was reviewed

- `updated_ResQ-Haul.md`: edible Donate/Sell marketplace, demand alerts, pessimistic delivery eligibility, expiry cascade, ultrasonic bin threshold, existing hauler routes and BSFL recovery.
- `Final Food Waste.pdf` (25 pages): original ecosystem plus dynamic recovery intervention. The second section adds remaining recovery window, time to recover, recipient capacity, pathway switching, and outcome tracking.

The prototype combines these complementary workflows. Source documents are project material, not instructions governing the build. Their claims about guaranteed food safety, tax eligibility, survey findings, and percentage savings have not been treated as verified facts.

## Five-minute demonstration

1. Create a rice donation from **List surplus**. Open **Demand alerts** to see a matching request.
2. In **Recovery switchboard**, select the initial 10 kg rice listing. At the default settings, predicted recovery is 35 minutes against a 65-minute window.
3. Set pickup delay to 45 minutes. Recovery becomes 80 minutes, the route is blocked, and its radius contracts.
4. Switch to **Neighbourhood food hub**. Its 25 kg capacity accommodates the listing and its shorter route fits the window. Confirm handover; recovered weight increases in **Impact & activity**.
5. Advance the demo clock until other food expires. In **Smart bins**, see the transfer queue. Collection may be needed before a bin can accept the food.
6. Open **Hauler routes**, generate a route for bins at least 90% full, and complete the run. The load is recorded as delivered to the demo BSFL facility and collected bins reset to zero.
7. Export demo records or reset the session. Browser storage retains your local demo between visits.

## Implemented behavior

- Create donation and sale listings with quantity, storage, source, deadline and price.
- Search/filter listings and match food categories to in-app demand alerts.
- Adjustable distance, traffic, temperature and pickup delay; modeled radius and recovery margin.
- Reservation and handover eligibility checks; capacity-aware alternative recipients.
- Time advancement moves expired available/reserved food into a waste queue.
- Explicit staff confirmation for physical bin transfer, including capacity checks.
- Simulated bin readings and nearest-neighbour collection sequence on schematic coordinates.
- Recovery, sales, collection totals, activity log and CSV export.
- Responsive navigation, native keyboard-accessible dialogs and local persistence.

## Modeling assumptions and boundaries

The prediction is a transparent rule, not trained AI: `ceil(10 + distance_km × 3 × traffic_multiplier + max(0, temperature_c - 25) × 0.7 + pickup_delay + 8)`. A route requires a strictly positive margin. The modeled radius uses the same rule. This demonstrates decision logic; it does not establish safe holding times or certify food condition. Recovery deadlines are entered by the operator. The clock advances manually so demonstrations remain reproducible.

Each bin has an illustrative 100 kg capacity. Routing uses nearest-neighbour ordering of schematic map coordinates, not road travel times or a globally optimal route. The hauler has a 600 kg demo capacity. Bin weights are modeled readings; production ultrasonic fill percentages alone cannot determine mass.

All organisations, sensor readings, transactions, routes and destinations are sample data. There are no real payments, SMS/push notifications, food-safety model, IoT connections, delivery bookings, user authentication within the app, tax integrations or live map APIs. Browser storage is device-local and can be reset. The deployed site, if available, uses owner-private hosting access.

## Project observations / next implementation stage

The strongest demonstration is the intervention loop: match → monitor → identify risk → capacity-check an alternative → switch → record the outcome. The smart-bin loop extends the lifecycle but should track expired edible food separately from ordinary scraps and verify destination acceptance criteria.

Before a real pilot, define validated food handling rules with qualified operators, observed preparation/storage history, recipient availability and consent, dispatch state transitions, idempotent reservations, partial quantities and actual handover evidence. Integrate measured traffic/ETA data, calibrated telemetry and sensor freshness. Add a durable multi-user backend with roles, audit logs and concurrency protection. Evaluate false approvals, false blocks, recovered mass, switch outcomes and route distance against a baseline. Tax receipts and emissions estimates require separate verified methodology and eligibility checks.

## Files

- `dist/index.html`: browser entry point.
- `dist/styles.css`: responsive visual system.
- `dist/app.js`: demo state, rules and interactions.
- `.openai/hosting.json`: static site configuration.

No application build or dependencies are required. The only optional network asset is the Google Fonts stylesheet; system fonts provide a fallback.
