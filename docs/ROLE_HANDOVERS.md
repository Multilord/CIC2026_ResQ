# Role journeys and handovers

## Sending and receiving with one account

Sending and receiving use one account type. After every login, choose **Send food** or **Receive food**. The selected mode determines the dashboard, visible recoveries and permitted actions for that session. Sign out and sign in again to choose a different mode. Separate sessions can choose different modes independently.

Existing sender and recipient accounts retain their identities, passwords and history; each now supports both modes. Sending displays that account's listings. Receiving displays other senders' available food and that account's accepted deliveries or offers. An account cannot receive its own listing. New combined accounts require administrator verification.

## Food redistribution

1. Sender publishes food; recipient accepts within capacity and the approved window.
2. Driver accepts the task and confirms collection condition.
3. Current holder confirms physical release to the assigned driver. Until then, custody stays with the holder.
4. Driver confirms arrival at the recipient.
5. Recipient inspects and accepts or rejects delivery.
6. After acceptance, the recipient can see the handover code. Driver verifies that code to complete delivery and transfer custody. Rejection sends the batch to recovery with driver custody retained.

Expiry blocks incomplete food handovers and sends the material to recovery without changing its physical holder. Route changes and recipient transfers are blocked while delivery inspection is underway.

## Organic recovery

1. Facility assesses suitability and capacity and selects BSFL, compost or biogas.
2. Hauler accepts the collection task. Pickup location reflects the current holder; destination is the accepting facility.
3. Hauler confirms collection condition; the current holder confirms release. This also applies to transfers between haulers. A hauler already holding the material can confirm onward transport without an artificial self-handover.
4. Hauler confirms arrival at the facility. Pickup alone does not enable facility inspection.
5. Facility weighs and inspects the load. Acceptance transfers custody to the facility; rejection leaves custody with the hauler and records the reason and measured weight.
6. Facility starts processing and records outputs and residue treatment before completion.

Permissions, confirmations, record versions, capacity and time checks are enforced by the API. Gemini recommendations cannot replace human inspection or handover decisions. These are user confirmations; live GPS arrival validation remains a separate integration.
