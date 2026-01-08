# Release Notes

## v0.2.0

### New Features
- **Settings Page**: Added a new settings page to toggle visibility of:
  - Feed
  - Explore
  - Reels
  - Stories
  - Notify Button
- **Notifications**: Added local notifications support. The app now checks for new DMs every 15 seconds and sends a system notification if unread messages are detected.
- **Offline Support**: Added a proper error page with a "Reload" button when no internet connection is detected.
- **Performance**: Optimized WebView settings for smoother performance.

### Bug Fixes
- **Blocked Features**: Fixed an issue where blocked Instagram features (Feed, Explore, etc.) would sometimes reappear.
- **Navigation**: Improved back button handling to prevent accidental app exits.

### Improvements
- **UI**: Added a custom loader (Instagram logo) while the web page is loading.
- **Architecture**: Refactored `dm_web_view.dart` for better code organization.
