# Spell Combat Resume Notes

## Completed

- Created the Flutter project scaffold in `spell_combat/`.
- Added dependencies to `spell_combat/pubspec.yaml`:
  - `audioplayers`
  - `flutter_animate`
  - `google_fonts`
  - `shared_preferences`
- Added the responsive dark title screen with:
  - Spell Combat branding and combat-typing tagline
  - Start Game navigation
  - Settings placeholder
  - Easy / Normal / Hard selector persisted with `shared_preferences`
- Copied the supplied enemy and combat icon artwork into `spell_combat/assets/icons/`.
- Added core models in `lib/models/`:
  - `LetterTile`
  - `Word`
  - `Player`
  - `Enemy`
  - `EnemyArchetype`
  - `GameState`
  - `Difficulty`
  - `BattleState`
- Added Scrabble-style values in `lib/utils/letter_values.dart`.
- Added `DamageCalculator` with centralized constants for:
  - Letter base damage
  - 5-letter and 7-letter bonuses
  - Bingo bonus
  - Combo multipliers
  - Optional Power Word bonus
- Added `LetterGenerator` with English frequency weighting, difficulty hand sizes, unique tile IDs, and at least two vowels per hand.
- Added `WordValidator` with an injectable dictionary interface, embedded common words, minimum length validation, and duplicate-aware hand validation.
- Added isolated enemy archetype hooks:
  - Shielded: halves damage from words shorter than 5 letters
  - Vowel Eater: removes a random vowel and refills one tile
  - Berserker: gains 50% attack power below 50% HP
  - Mimic: adds submitted tile values to its next attack
- Added `BattleController` using `ChangeNotifier` with:
  - Starting hand generation
  - Letter selection and deselection
  - Word clearing
  - Word validation and damage submission
  - Archetype modifiers
  - Enemy turns and win/loss state changes
  - Easy automatic Power Word behavior
  - Normal/Hard manual `usePowerWord()` behavior
  - `resetBattle()`

## Important Current Behavior

- Easy automatically uses a Power Word on the next valid submission once combo reaches 5.
- Normal and Hard expose Power Word through `usePowerWord()` once `powerWordReady` is true.
- Manual Power Word consumes the full hand, applies the optional Power Word bonus, resets combo, and refills the hand.
- The current default enemy is a 100 HP Shielded Goblin Scout.

## Next Work

1. Build the real BattleScreen around `BattleController`.
2. Add animated enemy/player HP bars, combo display, letter tiles, attack button, clear button, and Power Word button.
3. Add victory and defeat overlays.
4. Add visual feedback: damage numbers, tile transitions, enemy hit flash, screen pulse/shake, and animated HP changes.
5. Add audio service and placeholder sound hooks.
6. Add Settings controls for audio and difficulty.
7. Add onboarding / How to Play overlay.
8. Add full dictionary asset and profanity filtering process.
9. Add Survival mode and local high-score persistence.
10. Add unit tests for `WordValidator`, `DamageCalculator`, archetype hooks, and `BattleController`.
11. Install Flutter SDK, run `flutter pub get`, then test Chrome, Android, and iOS targets.

## Environment Note

Flutter and Dart were not installed in the environment during this session, so runtime builds and Flutter test execution still need to be performed after installing the SDK.

## Resume Prompt

Continue building the Spell Combat Flutter project in `/Users/thurtea/Work/untitled folder/spell_combat`.

The project already contains the scaffold, responsive title screen, persisted difficulty selector, core models, damage calculator, letter generator, word validator, isolated enemy archetype hooks, and a ChangeNotifier `BattleController` in `lib/services/battle_controller.dart`.

Next, build the functional `BattleScreen` around `BattleController`. It must display the enemy name and archetype, animated enemy HP, player HP, combo count, current word, selectable letter tiles, Clear, Attack, and conditional Power Word controls. Use the existing dark combat theme and supplied assets. Wire the controller with `ChangeNotifier` or a lightweight local listener pattern. Make sure Normal/Hard Power Word is visible only when `powerWordReady`, Easy Power Word remains automatic, and terminal victory/defeat states show Play Again controls. Respect system text scaling and keep tap targets at least 44x44 points. After implementation, run focused diagnostics and note that Flutter runtime tests require the SDK if it is still unavailable.
