import 'package:audioplayers/audioplayers.dart';

/// Centralized sound-effect and background-music playback for the game.
class AudioService {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  final AudioPlayer _sfxPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.stop);
  final AudioPlayer _musicPlayer = AudioPlayer()..setReleaseMode(ReleaseMode.loop);

  bool enabled = true;
  double volume = 0.8;

  bool musicEnabled = true;
  double musicVolume = 0.5;

  String? _currentMusicAsset;

  Future<void> _play(String asset) async {
    if (!enabled) return;
    try {
      await _sfxPlayer.stop();
      await _sfxPlayer.setVolume(volume);
      await _sfxPlayer.play(AssetSource('audio/$asset'));
    } catch (_) {
      // Playback failures (e.g. unsupported platform codec) must never crash gameplay.
    }
  }

  /// Plays a one-off sound effect by filename, for cues without a named
  /// helper below (e.g. newly added effects dropped into assets/audio/).
  Future<void> playEffect(String assetFileName) => _play(assetFileName);

  /// Starts looping background music. Does nothing if [assetFileName] is
  /// already the track currently playing. Safe to call even if the asset
  /// file does not exist yet (fails silently).
  Future<void> playMusic(String assetFileName) async {
    if (!musicEnabled) {
      _currentMusicAsset = assetFileName;
      return;
    }
    if (_currentMusicAsset == assetFileName) return;
    _currentMusicAsset = assetFileName;
    try {
      await _musicPlayer.stop();
      await _musicPlayer.setVolume(musicVolume);
      await _musicPlayer.play(AssetSource('audio/$assetFileName'));
    } catch (_) {
      // Music is optional polish; a missing/unsupported track must not crash gameplay.
    }
  }

  Future<void> stopMusic() async {
    _currentMusicAsset = null;
    try {
      await _musicPlayer.stop();
    } catch (_) {
      // Ignore stop failures; there is nothing meaningful to recover.
    }
  }

  Future<void> setMusicEnabled(bool value) async {
    musicEnabled = value;
    if (!value) {
      try {
        await _musicPlayer.stop();
      } catch (_) {
        // Ignore stop failures; there is nothing meaningful to recover.
      }
    } else if (_currentMusicAsset != null) {
      final asset = _currentMusicAsset!;
      _currentMusicAsset = null;
      await playMusic(asset);
    }
  }

  Future<void> setMusicVolume(double value) async {
    musicVolume = value;
    try {
      await _musicPlayer.setVolume(value);
    } catch (_) {
      // Ignore volume failures; there is nothing meaningful to recover.
    }
  }

  Future<void> buttonClick() => _play('button_click.wav');
  Future<void> letterSelect() => _play('letter_select.wav');
  Future<void> letterDeselect() => _play('letter_deselect.wav');
  Future<void> wordInvalid() => _play('word_invalid.wav');
  Future<void> wordCast() => _play('word_cast.wav');
  Future<void> hitEnemy() => _play('hit_enemy.wav');
  Future<void> hitPlayer() => _play('hit_player.wav');
  Future<void> powerWord() => _play('power_word.wav');
  Future<void> victory() => _play('victory.wav');
  Future<void> defeat() => _play('defeat.wav');
  Future<void> enemyTurn() => _play('enemy_turn.wav');
  Future<void> shuffle() => _play('shuffle.wav');
}

