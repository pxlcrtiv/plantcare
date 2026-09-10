# 13 — Privacy policy + Google Play Data Safety form

Type: task
Status: open
Blocked by: —

## Question

Google Play **requires** a published privacy-policy URL and a completed Data Safety declaration before any listing goes live. The app collects photos (camera/gallery), email (Firebase Auth), and plant data (Firestore). Without these, tickets 02 (listing) and 03 (beta) are physically impossible — Play Console rejects the listing.

Path:

1. **Privacy policy**: publish a static page (can be a GitHub Pages HTML file in the waitlist repo, or a standalone page on `platcare.app/privacy`) covering: what data is collected (photos, email, plant data), how it's used (identification, care scheduling), storage (Firebase/Firestore), third parties (PlantNet API, Google AI/Gemini), user rights (access, deletion). Keep it plain-English, not legalese.
2. **Play Data Safety form**: complete the Play Console declaration — data collection types (photos, email, user content), storage (cloud), sharing (PlantNet for identification), encryption (in transit), deletion mechanism (ticket 14).
3. **GDPR consent**: if targeting EU users, add an in-app consent banner for analytics/data collection (AdMob UMP integration is ticket 07; this ticket covers the app's own data).
4. **Verification**: privacy-policy URL loads in browser; Play Console Data Safety form completes without errors.

## Checklist

- [ ] Privacy policy published at a stable URL
- [ ] Play Console Data Safety form completed
- [ ] GDPR consent banner (if EU targeting) — or decision to defer
- [ ] URL tested in browser; no broken links
- [ ] Single concern commit; pushed
