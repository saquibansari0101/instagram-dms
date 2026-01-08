# Insta DM - Release Process Guide

This guide details how to build `Insta DM` for release on Android devices.

## 1. Prerequisites
Ensure you have the following installed:
-   Flutter SDK
-   Java JDK (Version 17 recommended)
-   Android Studio (for Android SDK command-line tools)

## 2. Configure Signing (Optional but Recommended)
By default, this project is configured to sign the release build with the **debug key**. This allows you to install the release APK without generating your own keystore, but it is **not secure** for the Play Store.

### To use your own Keystore (Secure):
1.  **Generate a keystore**:
    ```bash
    keytool -genkey -v -keystore my-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias my-key-alias
    ```
2.  **Create `android/key.properties`**:
    ```properties
    storePassword=YOUR_STORE_PASSWORD
    keyPassword=YOUR_KEY_PASSWORD
    keyAlias=my-key-alias
    storeFile=../my-release-key.jks
    ```
3.  **Update `android/app/build.gradle.kts`**:
    Uncomment or add the signing config to load from `key.properties`.

## 3. Building the APK
To build the optimized release APK:

```bash
flutter build apk --release
```

**Output Location**:
`build/app/outputs/flutter-apk/app-release.apk`

## 4. Building App Bundle (For Play Store)
If you intend to publish to Google Play:

```bash
flutter build appbundle --release
```

**Output Location**:
`build/app/outputs/bundle/release/app-release.aab`

## 5. Installing
Transfer the APK to your Android device and tap to install.
*Note: You may need to enable "Install from Unknown Sources" in your device settings.*

## 6. Troubleshooting
-   **App not installed**: If you have the debug version installed, uninstall it first before installing the release version (signatures must match).
-   **Build failures**: Run `flutter clean` and try again.
