Type: grilling
Status: resolved (2026-08-17)
Blocked by: 13

## Decision

- **Service shape**: one typed method per feature — `diagnosePlant`, `chatAboutPlant`, `suggestWateringSchedule`, `reminderTextFor`, `summarizeHealthLogs` — each with its own request/result models, encapsulating prompt, grounding, parsing, and error mapping.
- **Prompts**: const Dart strings in the service file, one private builder per feature. Grounding is caller-supplied in the typed request (photo bytes, species, profile, careSchedule, healthLogs, notes); the service never reads Firestore.
- **Output**: JSON schema (`GenerationConfig.responseSchema` + `responseMimeType: application/json`, verified in firebase_ai 3.15.0) for diagnosis, schedule, summary — strict `fromJson` with tolerant defaults; plain text for chat and reminder text; one-shot, no retries.
- **Model config**: `gemini-3.7-flash` for all features (2.5 Flash shuts down 2026-10-16). Per-feature table: diagnosis 0.3/1024, schedule 0.5/1024, summary 0.4/1024, chat 0.8/1024 (history truncated to last 12 messages), reminder text 0.8/256. Const config table in the service.
- **Error taxonomy**: sealed 6-way — `QuotaExceededError` (RESOURCE_EXHAUSTED/429 → resting card), `BlockedError` (safety → neutral no-blame), `TimeoutError` (→ retry), `MalformedOutputError` (→ resting/retry), `OfflineError` (checked before call), `UnknownError` (catch-all). UI mapping is 21/07's job.
- **Testability**: `typedef ModelCall = Future<GenerateContentResponse> Function(List<Content>, GenerationConfig)` injected via constructor (GenerativeModel is concrete in firebase_ai — function seam instead); unit tests cover prompt assembly, fixture-JSON parsing, error mapping (no Firestore in service); widget tests use `FakePlantAiService`; no live Gemini in CI (22/08 owns on-device verification).

Unblocks: 17, 18, 19, 20, 21, and slices 02–07.