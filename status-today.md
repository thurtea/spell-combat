# Spell Combat: Status (2026-09-22, updated)

## Completion: ~65-70% toward a shippable MVP

**Update: Flutter is now installed and the project is verified running on
this machine for the first time.** Flutter 3.47.5 (stable) was cloned to
`~/development/flutter` this session. `flutter pub get`, `flutter analyze`
(no issues), `flutter test` (22/22 passing, up from 1 default scaffold
test), and `flutter build web` (succeeds, `build/web`) all ran clean.
This closes the "not executed at all on this machine" gap the previous
entry below flagged as the project's single biggest risk.

**A real bug was found and fixed in the process:** the default
`widget_test.dart` (never actually run before) expected `find.text('SPELL\nCOMBAT')`
to match the title screen, but `lib/screens/title_screen.dart` built that
text as a raw `RichText(text: TextSpan(children: [...]))`, a widget type
Flutter's `find.text()` matcher does not match at all (it matches `Text`/
`Text.rich`/`EditableText`, not a bare `RichText`). Fixed by switching to
`Text.rich(TextSpan(...))`, the idiomatic higher-level widget for exactly
this case (same TextSpan tree, same visual result, now testable). Visual
output is unaffected; only the widget type changed.

**New test coverage** (`test/word_validator_test.dart`,
`test/enemy_roster_test.dart`, `test/battle_controller_test.dart`): the
three areas the previous entry below flagged as having zero coverage.
`WordValidator.isValid` (dictionary lookup, minimum length, letter-count
enforcement, case-insensitivity, a custom `WordDictionary` injection),
`EnemyRoster.starting()`/`nextAfter()` (the fight-order cycle and its
fallback), and `BattleController.shuffleHand()`/`rerollTile()` (charge
spending, hand/word mutation, exhaustion).

### Previous entry (now resolved), kept for context

Feature-complete on paper, unverified on this machine. Full Flutter app
per the handoff notes (`docs/handoff.md`): title screen, difficulty
select, battle screen with word-building combat, settings/How-to-Play,
win/lose overlays. Core systems all implemented: `BattleController`,
`WordValidator` (~1,800-word offline dictionary), `LetterGenerator`,
`DamageCalculator`, 4 enemy archetype hooks (Shielded, Vowel Eater,
Berserker, Mimic — only 3 wired into the roster). App icons wired via
`flutter_launcher_icons`; Android/iOS platforms scaffolded but never
built. The real blocker was Flutter/Dart not being installed anywhere on
this machine — see the update above, that is now fixed.

### Still open

- No background music files (`assets/audio/` has 12 synthesized SFX
  `.wav` files, no `music_menu.mp3`/`music_battle.mp3`).
- No Android build has ever actually been run through Android Studio;
  iOS untested even in a simulator. Still true, Android Studio/Xcode are
  a separate, heavier dependency than the Flutter SDK itself.
- No `linux/` platform target exists. `flutter build web` (now proven to
  work) is the realistic desktop-adjacent path on this machine; a real
  `linux/` target is `flutter create --platforms=linux .` if a native
  desktop build is ever wanted.
- `DamageCalculator`, the archetype hooks, and the enemy-turn flow still
  have no unit coverage. `BattleController`/`WordValidator`/`EnemyRoster`
  do now; those three were this narrower.
- Still nobody has looked at this running with actual eyes: `flutter
  build web` proves it compiles and boots, not that combat pacing, the
  dictionary's word list, or the UI layout feel right. A real playtest
  (`flutter run -d chrome`, or serving `build/web`) is still open.

## Next logical step

1. A real playtest: `flutter run -d chrome` (or serve `build/web`) and
   actually play a full battle on each difficulty. This is the one thing
   `flutter analyze`/`flutter test`/`flutter build web` cannot check.
2. Unit coverage for `DamageCalculator` and the four archetype hooks
   (Shielded, Vowel Eater, Berserker, Mimic) — same value proposition
   the three new test files above already established, just not done yet.
3. Only after a playtest confirms pacing feels right: record background
   music (or source placeholder tracks) for `music_menu.mp3`/
   `music_battle.mp3`.
