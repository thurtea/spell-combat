# Spell Combat Native Requirements

This project is intended to run in this order:

1. Android
2. macOS
3. iPhone / iOS Simulator
4. Browser only as a fallback

## Current Progress

| Component | Status | Next action |
| --- | --- | --- |
| Flutter | Complete | None |
| macOS desktop | Complete | Can run now |
| Xcode | Complete | None |
| CocoaPods | Complete | None |
| iOS Simulator runtime | Needs installation | Install from Xcode Settings |
| Android SDK | Not installed | Install Android Studio and SDK |
| Chrome | Optional | Safari web-server fallback works |

Run all Flutter commands from:

```sh
cd "/Users/thurtea/Work/untitled folder/spell_combat"
```

## Already Installed

- Flutter 3.47.4
- Dart 3.13.3
- Homebrew

## Android: Manual Install Required

Install Android Studio from the official site:

https://developer.android.com/studio

During Android Studio setup, install these SDK components from **More Actions > SDK Manager**:

- Android SDK Platform
- Android SDK Platform-Tools
- Android SDK Build-Tools
- Android SDK Command-line Tools
- Android Emulator
- An Android system image matching the Mac architecture, preferably an ARM64 image on Apple Silicon

In **Android Studio > Settings > Languages & Frameworks > Android SDK**, note the Android SDK Location.

Then configure Flutter. The default Apple Silicon location is usually:

```sh
flutter config --android-sdk "$HOME/Library/Android/sdk"
```

Accept Android licenses:

```sh
flutter doctor --android-licenses
```

Create and start an emulator from **Android Studio > Device Manager**, or connect an Android phone with Developer Options and USB debugging enabled.

Verify:

```sh
flutter doctor -v
flutter emulators
flutter devices
```

Run Spell Combat on Android:

```sh
flutter run -d <android-device-id>
```

## macOS: Ready

Full Xcode and CocoaPods are installed. macOS is already available to Flutter.

If Xcode needs to be selected again, run:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Open Xcode once and accept any license or additional-component prompts.

Verify:

```sh
flutter doctor -v
flutter devices
```

Run Spell Combat as a native macOS app:

```sh
cd "/Users/thurtea/Work/untitled folder/spell_combat"
flutter pub get
flutter run -d macos
```

## Immediate Next Step: Install an iOS Simulator Runtime

Xcode is installed, but Flutter still reports that no iOS Simulator runtime is available.

1. Open **Xcode**.
2. Open **Xcode > Settings**. On some versions this is **Xcode > Preferences**.
3. Open the **Components** or **Platforms** tab.
4. Download at least one iOS Simulator runtime.
5. Optionally open **Open Developer Tool > Simulator** and boot an iPhone simulator.

After installation, run:

```sh
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor -v
flutter devices
```

The iOS Simulator warning should disappear or improve, and an iPhone simulator should appear in `flutter devices`.

## iPhone / iOS Simulator: Remaining Setup

iOS development is ready after the simulator runtime is installed. A physical iPhone additionally requires an Apple ID configured in Xcode for signing.

For the simulator:

1. Open **Xcode > Open Developer Tool > Simulator**.
2. Create or boot an iPhone simulator.

For a physical iPhone:

1. Connect the iPhone by USB.
2. Tap **Trust** on the phone when prompted.
3. Enable Developer Mode on the phone if requested.
4. Add an Apple ID under **Xcode > Settings > Accounts**.
5. Open the iOS project in Xcode if signing configuration is requested.

Verify:

```sh
flutter devices
```

Run on an iPhone simulator or connected device:

```sh
flutter run -d <ios-device-id>
```

## Browser Fallback

Chrome is not required if using Flutter's web server and Safari:

```sh
cd "/Users/thurtea/Work/untitled folder/spell_combat"
flutter run -d web-server --web-port 8080
```

Open the printed `http://localhost:8080` URL in Safari.

## Final Verification

After installing the native requirements:

```sh
cd "/Users/thurtea/Work/untitled folder/spell_combat"
flutter pub get
flutter analyze
flutter test
flutter doctor -v
flutter devices
```

Expected native targets are Android, macOS, and iOS. Chrome is optional.

## Recommended Next Commands

Run macOS now:

```sh
cd "/Users/thurtea/Work/untitled folder/spell_combat"
flutter pub get
flutter run -d macos
```

After installing the iOS Simulator runtime:

```sh
flutter doctor -v
flutter devices
flutter run -d <ios-simulator-id>
```

After that, set up Android Studio and the Android SDK using the Android section above.