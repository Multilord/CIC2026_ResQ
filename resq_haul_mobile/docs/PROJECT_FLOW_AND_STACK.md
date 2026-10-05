# ResQ-Haul: prototype flow and stack

## Roles

| Role | Authority |
|---|---|
| Sender | Individuals, event hosts, kitchens, retailers and organisations publish food or organics, follow custody, cancel unclaimed listings and report issues. |
| Recipient | Verified accounts accept food within capacity/time limits; only the receiving account sees the handover code. |
| Driver / Hauler | Accept collections, confirm pickup, update arrival estimates and verify delivery with the recipient code. |
| Recovery Facility | Assess BSFL/compost/biogas suitability, accept requests, weigh/inspect loads, reject unsuitable material, record output and residue treatment. |
| Admin | Verify/suspend partners, resolve incidents, offer recipient transfers with verified arrival estimates, pause/resume AI. Reasons are audited. |
| Gemini coordinator | Backend service; recommends capacity-eligible participants, evaluates supplied route alternatives and escalates exceptions. |

## Food flow

1. Sender publishes source type, location, quantity, category, storage, allergens, donation/sale terms, approved remaining food window and journey estimate. The server stores actual UTC timestamps.
2. Gemini may recommend an available recipient with enough capacity. Recipient acceptance is explicit; the API independently enforces capacity and time limits.
3. A verified driver accepts the task. Pickup confirmation records driver custody.
4. For delays, the driver supplies the current ETA and same-recipient alternative ETA. Gemini may select only a faster alternative that meets the approved window.
5. If no alternative is viable, admin obtains a verified closer-recipient estimate and sends a transfer offer. The original destination remains until the new recipient accepts; driver custody continues.
6. Recipient inspects food and shares a random six-digit handover code. Driver submits it with the condition confirmation. The API then records delivery and a unique receipt.
7. Expired/unsuitable food moves to recovery with custody retained. AI never extends the approved window or certifies edibility.

## Organic recovery

1. Direct organic listings and expired food enter the recovery queue.
2. Facility confirms separation, suitability, route and capacity before accepting.
3. Hauler accepts and collects; facility weighs and inspects at arrival.
4. Rejected material returns to reassessment with a reason and custody history. It does not count as recovered.
5. Accepted material enters controlled processing. Completion requires output and residue-treatment records. Staff record actual completion; a timer does not pretend biological processing is instant.
6. Metrics count confirmed delivered food and completed measured facility loads.

## Technology

| Layer | Implementation |
|---|---|
| App | Flutter 3.38 / Dart 3.10, Material 3, navy/yellow tokens, bundled editorial font |
| Route display | Responsive Flutter map canvas with origin/destination markers, current and alternative paths, vehicle position and ETA labels |
| Networking | Dart http, memory-only bearer sessions, 10-second polling |
| Backend | Python standard-library HTTP service, loopback by default |
| Data | SQLite, serialized transactional commands, persistent users/sessions/recoveries/audit events |
| Identity | Salted scrypt passwords, random expiring tokens; locally bootstrapped admin |
| Permissions | Server roles, verification, ownership and state-transition checks |
| Concurrency | Record versions reject stale commands; serialized database writes |
| AI | Server-side Gemini generateContent, structured JSON, independently validated actions |
| Worker | Expiry/coordination every 30 seconds; expiry also evaluated on reads/commands |

Google reference: [structured output with generateContent](https://ai.google.dev/gemini-api/docs/generate-content/structured-output). Keys remain server-side. Model requests exclude names, exact locations, email and handover secrets; they include opaque candidate IDs, roles, capacity, timing and categories. Gemini uses task instructions and constraints, not custom training.

## Remaining integrations

Managed identity/password recovery, HTTPS deployment, rate limiting, monitoring/backups, live road-map/ETA providers, push messages, IoT hardware, payments and facility-specific policies are future integrations. The in-app route map visualizes the prepared paths and supplied ETAs; it does not claim live traffic or GPS navigation. Current matching checks capacity/status, not geographic optimization or dietary preferences. Human suitability checks are mandatory. Live Gemini calls require credentials and have not been verified on this machine.
