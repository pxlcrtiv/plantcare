Type: prototype
Status: resolved (2026-08-17)
Blocked by:

## Decision

- **Hub layout**: header "Care Assistant" + subtitle "Your AI partner for keeping every plant thriving"; two entry cards — Plant Doctor ("Snap a photo and get an instant health diagnosis.") and Care chat ("Ask anything about watering, light and repotting.") — olive-tinted icon badges on `primary.withValues(alpha: 0.1)`.
- **Flask dock tab**: index 3 of the IndexedStack swaps the DiagnosticsTab placeholder for the hub; DiagnosticsTab class removed, IdentifyTab stays.
- **Navigation**: `Navigator.push` + `MaterialPageRoute` into stub screens ("Coming soon" + feature description) for not-yet-built destinations.
- **Contextual entries**: the hub's two entry cards are the routing surface. Home scan area keeps its current behavior (PlantNet identify flow — spec 23 keeps PlantNet as the identification engine; routing it into the hub would regress it). Plant detail gets no AI action in this ticket — "ask about my plant" deep-links are feature work for 17/18.
- **Empty/offline states**: hub always renders the entry cards (never dead-ends); offline banner via connectivity_plus (mirroring sync_service.dart); "assistant is resting / Try again in a moment." notice when the service reports unavailable (spec 23 language). Deep degradation UX is 21/07's job.
- **Built by slice 01** (wf/01-care-assistant-hub, commit `e9b35a8`): hub turned into the real hub with `PlantAiService` seam (`isAvailable()`) + `PlantAiServiceProvider`; 5 widget tests (rendering, navigation ×2, resting, offline); baseline 52 → 54 tests.