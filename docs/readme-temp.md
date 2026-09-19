Spell Combat: Complete Concept & Build Prompts
(Fully updated with difficulty system, letter values, combo/power-word, bingo, enemy archetypes, survival mode, accessibility, and polished $0.99 scope)


Part 1: Refined Concept

Core Fantasy
You are dealt a hand of letters. You tap them to form words and attack. Damage is based on the actual letters used (Scrabble-style values), word length, bingo bonus, and a combo meter. Enemies have distinct gimmicks that force different strategies. The game is turn-based, short-session friendly, and designed to feel worth $0.99.

Damage Formula

base = sum of each letter’s point value
length_bonus = +10 if length ≥ 5, +20 if length ≥ 7
bingo_bonus = +25 if every tile in the current hand was used
combo_multiplier = 1.0 normally, 1.25 at combo ≥ 3, 1.5 at combo ≥ 5
damage = round((base + length_bonus + bingo_bonus) * combo_multiplier)
Combo Meter & Power Word

Consecutive successful attacks increase the combo count.
Wasting a turn (invalid word, clearing without attacking, or submitting a word under 3 letters) resets the combo.
At combo 3 the multiplier kicks in.
At combo 5 a Power Word becomes available: it clears the entire hand for bonus damage and resets the combo after use.
Difficulty Modes

Aspect
Easy
Normal
Hard
Power Word
Automatic on next valid word
Player chooses (button appears)
Player chooses (button appears)
Enemy HP & Damage
Baseline
+25–35%
+60–80%
Starting hand size
8 letters
9 letters
10–11 letters
Extra tools
None
None
+1 free Shuffle per fight or +1 Reroll-one-letter charge
Feel
Forgiving, flow-focused
Balanced agency
High agency + real pressure
Enemy Archetypes (3–4 simple rules that change strategy)

Shielded: Takes reduced damage from words shorter than 5 letters.
Vowel Eater: Removes one random vowel from the player’s hand at the start of its turn.
Berserker: Attack power increases as its own HP percentage drops.
Mimic: After the player submits a word, those letters (or a subset) are added to the enemy’s next attack calculation.
Survival Mode
One continuous run against a sequence of enemies that slowly increase in power and cycle through archetypes. Local high-score tracking only (enemies defeated). No story, no accounts.

Monetization
Paid up-front at $0.99. No ads, no IAP, no backend, no accounts at launch.

Accessibility (cheap but important)

Respect system text scale.
Selected letters and damage feedback use both color and shape/icon change.
All tap targets ≥ 44×44 points.
Stack
Flutter (Dart). Single codebase for iOS, Android, and web. Local persistence via shared_preferences.


Part 2: Complete Prompt Sequence

Copy everything below into a file named PROMPTS.md. Work through the prompts in order. Test after each prompt (or every two) before continuing. When something feels wrong, describe the exact issue before moving on.

Project Target
Flutter (Dart), single codebase for iOS + Android + web. Turn-based word combat game. Player is dealt a hand of letters, taps them to build a word, and submits it to attack. Damage uses letter point values, length bonuses, bingo bonus, and a combo meter. A Power Word becomes available at high combo (behavior changes by difficulty). Enemies have distinct archetypes. Includes background music, sound effects, difficulty modes, and a Survival mode. Sold as a one-time $0.99 purchase with no ads and no IAP.


Phase 1: Project Scaffolding

Prompt 1.1 – Create the project
Create a new Flutter project called spell_combat using the latest stable Flutter. Structure it with these folders under lib/:

main.dart
models/
screens/
widgets/
services/
utils/
audio/
data/
Add these dependencies to pubspec.yaml:
audioplayers (or just_audio), shared_preferences, google_fonts, flutter_animate.

Set up a dark theme suited to a combat and typing aesthetic: deep near-black background (#0D0D0D), high-contrast letter tiles, and a single red-orange accent color reserved for damage and attack feedback.

Build a MaterialApp with a title screen that shows the game name, a short tagline, a prominent Start Game button that navigates to an empty BattleScreen placeholder, and a Settings button (leave Settings empty for now).

Prompt 1.2 – Navigation and theme polish
Refine the theme and navigation:

Background around #0D0D0D with a clearly distinct surface color for cards and tiles.
One accent color used consistently for damage numbers, attack buttons, and highlights so it always reads as “this means attack”.
Clean sans-serif font that remains readable at small sizes on phone screens.
Title screen shows the game name, short tagline, Start button, Settings button, and a difficulty selector (Easy / Normal / Hard) that is already functional and persisted.
Confirm the layout is fully responsive and looks correct on both a phone-sized viewport and a wider desktop/web viewport.
Respect the system text scale setting rather than hard-coding font sizes.

Phase 2: Core Models and Logic

Prompt 2.1 – Core data models
Create these models in lib/models/:

LetterTile: letter, point value, isSelected, unique id.
Word: the current in-progress string and the list of tile ids used to build it.
Player: hp, maxHp, name.
Enemy: hp, maxHp, name, baseAttackPower, archetype.
GameState enum: playerTurn, enemyTurn, victory, defeat, menu.
Difficulty enum: easy, normal, hard.
BattleState: holds player, enemy, current hand of letters, current word, combo count, turn number, current difficulty, and any temporary power-word or shuffle charges.
Also create a LetterValues utility that assigns Scrabble-style point values to every letter (common letters low, rare letters such as Q, X, Z, J higher).

Prompt 2.2 – Damage calculation
Create a DamageCalculator service. Given the letters used in a submitted word and the current combo count, it returns damage using this exact formula:

base = sum of each letter’s point value
length_bonus = +10 if word length ≥ 5, +20 if word length ≥ 7
bingo_bonus = +25 if every tile in the current hand was used
combo_multiplier = 1.0 normally, 1.25 at combo ≥ 3, 1.5 at combo ≥ 5
damage = round((base + length_bonus + bingo_bonus) * combo_multiplier)
All constants must live in one easy-to-tune place. The calculator must also support an optional Power Word bonus that can be applied when the player (or the auto system on Easy) triggers it.

Prompt 2.3 – Letter generation and word validation
Create a LetterGenerator service that produces a hand of letters using English frequency weighting while guaranteeing at least two vowels in every hand. Hand size is driven by difficulty:

Easy → 8 letters
Normal → 9 letters
Hard → 10 or 11 letters
Create a WordValidator service that checks:

Word length is 3 or more.
The word exists in the dictionary.
The letters used are actually available in the current hand (respecting duplicate counts).
For now use a small embedded list of common English words. Leave a single clear method call so the full dictionary can be swapped in later without touching other code.

Prompt 2.4 – Enemy archetypes
Add an EnemyArchetype enum with these values: shielded, vowelEater, berserker, mimic.

Implement each effect as an isolated hook the BattleController calls at the correct moment:

Shielded: reduce incoming damage by a percentage when the attacking word is shorter than 5 letters.
Vowel Eater: remove one random vowel from the player’s hand at the start of the enemy’s turn, then refill from the letter pool.
Berserker: increase the enemy’s own attack power as its remaining HP percentage drops.
Mimic: after the player submits a word, add those same letters (or a subset) into the enemy’s next attack calculation.
Keep each archetype’s logic completely isolated so a new archetype can be added later without touching the others.

Prompt 2.5 – Battle controller
Create a BattleController using ChangeNotifier (or the simplest Provider/Riverpod approach you prefer) that manages the full turn loop:

Generating the starting hand according to current difficulty.
Selecting and deselecting letters to build the current word.
Submitting a word: validate → calculate damage (including archetype modifiers) → apply damage to the enemy → update combo count → handle Power Word (auto on Easy, manual button on Normal/Hard) → clear used tiles → refill the hand.
Switching to the enemy’s turn and applying its attack, including all archetype effects.
Checking win and lose conditions.
Resetting state for a new battle.
Exposing clear methods: selectLetter, deselectLetter, clearWord, submitWord, usePowerWord, enemyTurn, resetBattle.
Power Word behaviour must respect difficulty exactly as defined in Part 1.


Phase 3: UI and Feel

Prompt 3.1 – Battle screen layout
Build the BattleScreen:

Top: enemy name, archetype indicator (icon + short label, never colour alone), and an animated HP bar.
Middle: the current word being built, shown large and clearly, plus an Attack button that is only enabled when the word is valid. On Normal and Hard, also show a Power Word button that appears only when combo ≥ 5.
Bottom: the hand of letter tiles in a comfortable grid or row, a Clear button, and (on Hard) the free Shuffle or Reroll charge indicator.
Player HP bar and combo meter displayed clearly so they never compete visually with the enemy HP bar.
Use generous spacing and ensure every tappable element has a touch target of at least 44×44 points.

Prompt 3.2 – Letter tile interaction
Make the letter tiles satisfying:

Tapping a tile animates it from the hand into the current word area with a short scale or fade transition.
Selected tiles change appearance using both a colour change and a shape or icon change so the state is readable without relying on colour alone.
The Attack button (and Power Word button when available) pulses or glows once the current word is valid.
After a successful attack, used tiles fade or pop out and replacement tiles animate into the hand.
Prompt 3.3 – Feedback and juice
Add strong game feel:

Floating damage numbers that rise and fade after an attack, showing the exact damage dealt.
A brief screen shake or pulse on high-damage hits and on Power Word use.
HP bars that animate smoothly rather than snapping.
A colour flash on the enemy when it takes damage.
A visible combo counter that appears and grows with the combo count and resets with clear feedback when a turn is wasted.
Victory and Defeat overlays, each with a Play Again button. The Victory overlay also shows a short summary of words used and total damage dealt.

Phase 4: Audio

Prompt 4.1 – Audio system
Build an AudioService using audioplayers or just_audio that supports:

Looping background music at a lower default volume than sound effects.
Sound effects for: letter select, invalid word, successful attack, Power Word, enemy attack, victory, defeat.
Independent mute toggles and volume sliders for music and sound effects, all persisted with shared_preferences.
If audio files are not yet present, use clearly labelled placeholder comments showing exactly where each sound should hook in.

Prompt 4.2 – Wire audio into gameplay
Connect AudioService to the BattleController and UI so that:

Music starts when entering a battle and stops or changes on victory or defeat.
The correct sound effect plays for every important action (letter tap, invalid attempt, successful attack, Power Word, enemy attack, victory, defeat).

Phase 5: Content, Balance and Modes

Prompt 5.1 – Full dictionary with profanity filtering
Replace the small embedded word list with a full English word list (filtered SCOWL-based list in the 20 000–50 000 word range) bundled as an asset and loaded efficiently at startup so validation stays fast.

Run the word list through a profanity filter at build time (or maintain a clear exclusion list) and remove flagged entries before bundling the asset.

Prompt 5.2 – Balance pass
Tune all numbers with real playtesting in mind:

Starting HP for the player and for each enemy archetype under each difficulty.
Letter point values and the length / bingo bonus constants.
Enemy attack power per archetype and how steeply the Berserker scales.
Exact hand sizes and the strength of the Hard-mode free Shuffle or Reroll.
Aim for individual fights to last roughly 2–5 minutes on Normal.

Prompt 5.3 – Survival mode
Add a Survival mode: a continuous run against a sequence of enemies whose HP and attack power slowly increase while cycling through the archetypes. The chosen difficulty fully applies (hand size, Power Word behaviour, enemy scaling, extra tools). Track the player’s best survival score (number of enemies defeated) locally with shared_preferences and display it on the title screen.

Prompt 5.4 – Settings and onboarding
Build a complete Settings screen containing:

Music volume and mute toggle
Sound-effect volume and mute toggle
Difficulty selector (Easy / Normal / Hard) that is also available on the title screen before starting a fight or Survival run
Add a short How-to-Play overlay that appears automatically on first launch. It must cover: how to select letters, what the combo meter and Power Word do (including the difference between Easy auto and Normal/Hard manual), what the bingo bonus is, and a one-line explanation of each enemy archetype.


Phase 6: Testing and Release

Prompt 6.1 – Cross-platform check and unit tests
Write unit tests for WordValidator and DamageCalculator covering normal cases, edge cases (empty word, word longer than hand, duplicate letters), bingo bonus, and Power Word application under each difficulty.

Confirm the game runs correctly on Flutter web (desktop testing), an Android emulator or device, and an iOS simulator or device when on the Mac. Fix any responsive-layout or performance issues so the game holds 60 fps during normal play.

Prompt 6.2 – Release preparation
Prepare the project for store submission:

Final app name, short description, and a placeholder icon.
Splash screen.
Version numbering.
A short privacy note confirming that no personal data is collected (only local settings and high scores are stored).
Clear step-by-step instructions for building a release APK/AAB for Android and an archive build for iOS.

How to Use This Document

Save the entire content as PROMPTS.md.
Create the Flutter project and open it in Cursor or VS Code.
Start a fresh conversation with your coding assistant and paste Prompt 1.1.
After the code is generated, run the app (flutter run -d chrome or on a device).
Move to the next prompt only after testing. When something is broken or feels off, describe the exact problem before continuing.
By the end of Phase 3 the core loop should be fully playable. Phase 4 adds audio. Phase 5 adds the depth (letter values, difficulty, archetypes, Survival) that makes the game worth $0.99.
This is the complete, ready-to-execute specification.