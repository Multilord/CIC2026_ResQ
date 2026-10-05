# ResQ-Haul interface direction

ResQ-Haul is a Flutter workspace for senders, recipients, haulers, recovery facilities and administrators. It supports surplus listing, verified handovers, time-sensitive routing and organic recovery after expiry.

## Visual direction

Use the supplied food-cycle symbol: a green bowl, produce and circular recovery arrows. Keep its transparent circular silhouette in the app and place it on cream for platform launcher icons. Pair a warm cream canvas with white surfaces, forest-green text and primary controls, pale leaf-green navigation, and citrus-orange and golden-yellow accents. Use darker green and orange shades for readable text. The wordmark combines green “ResQ” with orange “-Haul”. Use the bundled editorial typeface for page titles and ordinary sans serif text for operational details. Keep restrained corner radii, consistent spacing and clear separators.

## Brand palette

Use the supplied green tile at `resq_haul_mobile/assets/images/resq-haul-dashboard-logo.png` in the signed-in workspace header and desktop sidebar. Keep the transparent food-cycle symbol on the login screen.

| Use | Colour |
| --- | --- |
| Cream canvas | `#FCFAEE` |
| Forest text | `#073D2A` |
| Green controls | `#007A3D` |
| Pale leaf surfaces | `#E7F0D9` |
| Lime accent | `#77BD24` |
| Citrus orange | `#FF9500` |
| Golden yellow | `#FFBE00` |
| Readable orange text | `#B85B00` |

The supplied brand sheet is the reference. The wordmark displays the original sprite pixels from `resq_haul_mobile/assets/images/resq-haul-brand-sheet.png`, preserving the supplied lettering and leaf inside the Q. The transparent symbol lives at `resq_haul_mobile/assets/images/resq-haul-logo.png`; platform icons use the same symbol on cream. The symbol was created with the built-in image tool using this extraction prompt:

> Extract only the supplied food-cycle symbol: green bowl with white leaf, orange bread, red-orange apple, green leaves, two circular green recycling arrows and golden emphasis marks. Preserve its identity, colours, gradients and arrangement. Centre the symbol on transparent alpha with safe padding. Remove wordmarks, square containers, other variants, palette and background. No new logo design or text.

## Interaction priorities

- Keep every active journey visible. Prioritize exceptions without hiding other work.
- Put pickup, ETA, stage and remaining food time together on journey cards.
- Show destination and custody before secondary handling details in the journey view.
- Keep persistent bottom navigation on phones; use a sidebar and two-column queue on wide screens.
- Preserve server authorization, confirmations, expiry and custody checks.
- Give fields persistent labels, password visibility, keyboard submission and disabled loading states.
- Avoid presentation labels in user-facing screens, as requested by the project owner.

## Verification

Review signed-in phone and desktop screenshots, including a routing detail sheet. Check narrow layouts for all five roles, authentication, queue completeness and responsive navigation. Routing displays prepared paths and estimates; live navigation remains a separate integration.

Direction informed by the requested [Astra frontend design skill](https://github.com/Enixes/astra-frontend-design/blob/main/SKILL.md).
