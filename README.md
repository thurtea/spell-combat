# Spell Combat

Flutter scaffold for a turn-based word combat game. The title screen uses the supplied combat artwork as the visual reference and includes responsive layout, dark theme styling, navigation placeholders, and locally persisted difficulty selection.

## Run

Install the latest stable Flutter SDK, then run:

```sh
flutter pub get
flutter run -d web-server --web-port 8080
```

Open the printed `http://localhost:8080` URL in Safari or another browser. This does not require Google Chrome.

For the native macOS app, install Xcode and run:

```sh
flutter run -d macos
```

For a web build, Chrome must be installed and detected by Flutter:

```sh
flutter run -d chrome
```

Reference artwork is bundled under `assets/icons/`.# spell-combat
