# Sangam Pro patch bundle

## Included patches
- Patch 1: Owner/staff login UX update
- Patch 2: Clean shop setup without demo data
- Patch 3: Settings + team management + share staff login flow
- Patch 4A: Dashboard cleanup, removed sensor tilt and fake notification button

## How to apply
1. Extract this zip.
2. Copy the `lib/` folder from this bundle into your `sangam_pro/` root.
3. Allow file replacement.
4. Run:
   - `flutter clean`
   - `flutter pub get`
   - `flutter run`

## Notes
- This bundle intentionally hides cloud sync in settings because your local project showed provider mismatch during build.
- This bundle does not yet add Notification Listener Android native files.
- If you want, the next bundle should include Android native changes for NotificationListenerService and manifest cleanup.
