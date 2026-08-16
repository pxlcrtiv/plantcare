Type: task
Status: open
Blocked by: 05

## Question

Restyle the entire app to the design in the reference screenshot (`/Users/admin/Desktop/Screenshot 2026-08-16 at 18.34.45.png`), restructure navigation to its 5-tab dock, and wire the mockup's data/actions into the plant model.

The user provided a screenshot of the target design — **warm botanical minimalism** — and answered the grilling pass (2026-08-16) as follows:

- **Scope**: everything — all screens (onboarding, login, add-plant wizard, profile included), not just the 3 mockup screens.
- **Navigation**: replace the current 4-tab bar (My Plants / Calendar / Camera / Profile) with the new 5-tab dock: **Home** (new dashboard), **Plant** (My Plants list), **Search** (plant database browser), **Flask** (diagnostics placeholder), **Target** (camera / identify). Calendar + Profile move behind the dashboard header (hamburger menu).
- **Data**: wire, don't mock — add `humidity` / `light` fields to the plant model; greeting uses the Firebase user's display name + device locale for the city line.
- **Typography**: keep the current font stack (Inter via google_fonts) — restyle sizes/weights/colors only.
- **Imagery**: keep Unsplash network images.
- **Theme mode**: keep both light + dark; derive a dark variant from the new palette.
- **Actions**: wire what's cheap — "View all" → list screen, "Add details" → existing detail/edit, "+" → add-plant wizard.
- **Base branch**: `run/first-boot` (carries the 3 runtime fixes + working PlantNet).

Design spec extracted from the screenshot (via multimodal subagent):

- Palette: off-white bg `#F5F5F0`, olive/yellow-green accent `#8CB23E`, white cards, text `#2D2D2D` / `#888888`, metric colors (thermometer ≈ orange, sun ≈ yellow `#F5C842`, droplet ≈ blue).
- Shapes: large card radii (~16–24 dp), pill buttons (radius ≥ 24), floating dock.
- Screen A (Home): greeting header ("Hi David !", city line) with hamburger + QR/scanner icons, decorative curved green stroke, Indoor/Outdoor/Both pill tabs (Indoor selected), "My Plants" horizontal scroll of white rounded cards (~45% width) with photo + metric icon row (thermometer 130% / sun "Sunny" / droplet 100), "Popular plants" vertical list with "+" buttons, "View all" links.
- Screen B (Plant detail): hero photo with green wash, right-side stat stack (Size / Humidity / Light), bottom sheet card "How to water" + italic tip + thumbnail row, "Add details" pill button.
- Screen C (Scan results): hero + gradient overlay, "Scan your plants" panel with category result items (e.g. Monstera plants / Foliage plants).

Work:
1. Theme system: new palette + radii + pill shapes in `lib/theme/app_theme.dart`, both light + dark.
2. Shared widgets: floating 5-tab dock, pill tab row, section header ("Title" + "View all"), metric icon row — in `lib/widgets/` or the dashboard widgets dir.
3. Navigation restructure: shell with the 5 destinations mapped as above; Calendar + Profile reachable from header menu.
4. Home dashboard per Screen A.
5. Plant detail per Screen B; scan results per Screen C.
6. Restyle onboarding / login / add-plant wizard / profile.
7. Plant model: `humidity` / `light` fields (+ toMap/fromMap + add/edit forms); greeting from `FirebaseAuth` display name + `Intl`/locale for city.

Evidence required: `flutter analyze` clean, full test suite green (fix tests that assert old colors/text as needed), emulator screenshots of Home / Plant detail / scan results.