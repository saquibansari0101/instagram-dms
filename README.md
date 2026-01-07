# Instagram DM Wrapper

A focused, distraction-free Instagram Direct Messages (DM) wrapper built with Flutter.

## Overview

This application serves as a dedicated "DM-only" client for Instagram. It wraps the Instagram web interface (`instagram.com/direct/inbox/`) and aggressively filters out distraction-heavy features like the Feed, Reels, and Explore pages using CSS injection and navigation interception.

## Features

-   **DM Focused**: Boots directly into the DM inbox.
-   **Distraction Blocking**:
    -   Hides the main Feed, Reels tab, and Explore tab.
    -   Removes home navigation links.
    -   Blocks navigation to `/`, `/explore`, and `/reels` URLs.
-   **Immersive UI**:
    -   Full-screen edge-to-edge design.
    -   Hidden internal "Back" buttons to prevent accidental exits to the Feed.
-   **Native Feel**:
    -   Handles Android back gesture correctly (navigates web history instead of closing app).
    -   Maintains a dark-themed aesthetic.

## Tech Stack

-   **Framework**: Flutter
-   **WebView**: `flutter_inappwebview`
-   **Method**: CSS Injection & URL Interception

## Getting Started

### Prerequisites

-   Flutter SDK installed
-   Android Studio / Xcode (for iOS) installed

### Installation

1.  Clone the repository:
    ```bash
    git clone https://github.com/saquibansari0101/instagram-dms.git
    ```
2.  Navigate to the project directory:
    ```bash
    cd insta-wrapper-dm
    ```
3.  Install dependencies:
    ```bash
    flutter pub get
    ```
4.  Run the app:
    ```bash
    flutter run
    ```

## Building for Release
See [RELEASE.md](RELEASE.md) for detailed instructions on building and signing the app.

## Development

-   **`lib/dm_web_view.dart`**: Contains the WebView logic, CSS injection scripts, and navigation delegates.
-   **`lib/main.dart`**: Main entry point and theme configuration.

## License

MIT
