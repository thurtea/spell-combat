import 'package:audioplayers/audioplayers.dart';

/// Centralized sound-effect playback for every meaningful game action.
class AudioService {
  AudioService._internal();

  static final AudioService instance = AudioService._internal();

  final AudioPlayer _player = AudioPlayer()..setReleaseMode(ReleaseMode.stop);

  bool enabled = true;
  double volume = 0.8;

  Future<void> _play(String asset) async {
    if (!enabled) return;
    try {
      await _player.stop();
      await _player.setVolume(volume);
      await _player.play(AssetSource('audio/$asset'));
    } catch (_) {
      // Playback failures (e.g. unsupported platform codec) must never crash gameplay.
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
