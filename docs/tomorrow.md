# Spell Combat — Session Handoff (2026-09-19)

Repo: https://github.com/thurtea/spell-combat
Local: `/Users/thurtea/Work/untitled folder/spell_combat`
Handoff / requirements: `docs/handoff.md`, `docs/requirements-temp.md`

macOS launcher snapshot (rebuild after code changes):
`/Applications/Spell Combat.app` (Desktop symlink available)

---

## Progress

### Done

- Full Flutter app: title screen, difficulty select, battle screen, settings,
  How to Play, win/lose overlays
- Core systems: `BattleController`, `WordValidator` (~1800-word offline dict),
  `LetterGenerator`, `DamageCalculator`, enemy archetype hooks (Shielded,
  Vowel Eater, Berserker, Mimic)
- Art: enemy sprites + SVG combat icons under `assets/icons/`
- App icons wired via `flutter_launcher_icons` (Android/iOS/macOS/web) from
  goblin Spell Combat logo; `android/` and `ios/` platforms scaffolded
- Audio: SFX player + looping BGM (`playMusic` / music settings persisted).
  Drop files into `assets/audio/` as `music_menu.mp3`, `music_battle.mp3`
  (missing files fail silently)
- Material flash/fire icons replaced with `lightning.svg` / `fire.svg`
- Encounter flow: every new battle **starts on Goblin Scout**; **Play Again**
  rotates Goblin → Salamander → Dragon → Goblin
- Normal softened: more shuffle/reroll charges; Salamander/Dragon stats nerfed
  slightly. Difficulty now mainly tunes resources, not which foe you face first

### Not done / next

1. Drop real `music_menu.mp3` / `music_battle.mp3` (and any extra SFX) into
   `assets/audio/`, then rebuild the macOS app if you want the Desktop launcher
   to pick them up
2. Human playtest Easy / Normal / Hard full runs; tune enemy-turn Timer pacing
   in `lib/screens/battle_screen.dart` if it still feels off
3. Unit tests for `BattleController` (shuffle/reroll), `WordValidator`,
   roster rotation (`EnemyRoster.starting` / `nextAfter`)
4. Android build via Android Studio (clone `thurtea/spell-combat`, Flutter+Dart
   plugins, SDK Manager, `flutter doctor --android-licenses`)
5. Optional polish: battle background art, HP damage-preview trail, idle enemy
   animation, Survival mode / high scores

---

## Useful rebuild (macOS app icon on Desktop)

```
cd "/Users/thurtea/Work/untitled folder/spell_combat"
flutter build macos --release
rm -rf "/Applications/Spell Combat.app"
cp -R "build/macos/Build/Products/Release/spell_combat.app" "/Applications/Spell Combat.app"
```

---

## Resume prompt (paste into Claude Code / Cursor)

```
Continue the Spell Combat Flutter project.

Repo: https://github.com/thurtea/spell-combat
Local path if present: spell_combat/ (handoff in docs/).

Already playable: title, difficulty, battle with word-building combat, 3 enemy
archetypes, SVG combat icons (no emoji thunder/fire), synthesized SFX,
background-music hooks + Settings music controls, launcher icons, Android/iOS
scaffolding. New battles always start on Goblin Scout; Play Again rotates the
roster. Normal has more shuffle/reroll charges than before.

Next, in priority order:
1. If audio files were added under assets/audio/, wire any new named SFX the
   same way as hitEnemy()/wordCast(), keep missing-file silent failure.
2. Playtest a full run (title -> difficulty -> battle -> win/lose -> Play Again
   / menu). Confirm Goblin-first + rotation. Tune enemy-turn Timer pacing in
   lib/screens/battle_screen.dart if needed.
3. Add unit tests for BattleController.shuffleHand()/rerollTile(), WordValidator,
   and EnemyRoster.starting()/nextAfter().
4. Verify Android build in Android Studio; iOS when a simulator runtime is ready.
5. Optional polish only after the above: battle background, HP preview trail,
   idle enemy animation.

Keep the dark/ember/arcane-blue/mystic-purple theme. Do not reintroduce emoji
icons or placeholder strings. Prefer assets/icons/*.svg for combat glyphs.
```
