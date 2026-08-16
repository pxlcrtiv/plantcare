# 01 — Care Assistant hub

**What to build:** The Flask dock tab stops being a "coming soon" placeholder and becomes the Care Assistant hub. From here the user discovers and reaches every AI feature: a Plant Doctor entry card and a Care chat entry card, laid out per the hub prototype (wayfinder 16). Contextual entries elsewhere in the app — the Home scan area and the plant detail screen — route into the hub or straight to its destinations. The hub renders sensible empty and offline states and never dead-ends; feature destinations that are not yet built show a graceful stub.

**Blocked by:** None on the implementation chain — can start immediately once wayfinder 13 (AI Logic provisioning), 14 (service design) and 16 (hub prototype) land.

**Status:** ready-for-agent

- [ ] Flask dock tab shows the hub with entry cards for Plant Doctor and Care chat, matching the approved prototype
- [ ] Tapping an entry card navigates to its destination (stub screens acceptable for not-yet-built features)
- [ ] Contextual entries (Home scan area, plant detail) route into the hub or its destinations
- [ ] Empty and offline states render without dead ends
- [ ] Widget tests cover hub rendering, navigation, and empty/offline states via the injected fake service
- [ ] `flutter analyze` clean; full test suite green