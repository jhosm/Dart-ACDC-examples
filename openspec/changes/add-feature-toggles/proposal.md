# Change: Add Feature Toggles

## Why
Users need to interactively enable/disable Dart-ACDC features (auth, caching, offline detection) and see the effect in real-time logs and a live code snippet panel.

## What Changes
- **Feature Toggles Panel** – Switches for Auth, Caching, Offline Detection
- **Authentication Toggle** – Enable/disable auth + Client ID input
- **Caching Toggle** – Enable/disable cache + TTL configuration
- **Offline Detection Toggle** – Simulate offline mode with visible indicator
- **Code Snippet Panel** – Live `AcdcClientBuilder` code reflecting current toggles

## Impact
- **Depends on**: `add-core-showcase-layout`
- **Affected specs**: `showcase-toggles` (new capability)
- **Affected code**: New toggle widgets, main.dart state management
