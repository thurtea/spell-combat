import 'package:shared_preferences/shared_preferences.dart';

import '../models/difficulty.dart';

class SettingsService {
  static const _difficultyKey = 'difficulty';
  static const _soundEnabledKey = 'sound_enabled';
  static const _volumeKey = 'sound_volume';

  Future<Difficulty> loadDifficulty() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_difficultyKey);
    return Difficulty.values.firstWhere(
      (difficulty) => difficulty.name == value,
      orElse: () => Difficulty.normal,
    );
  }

  Future<void> saveDifficulty(Difficulty difficulty) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_difficultyKey, difficulty.name);
  }

  Future<bool> loadSoundEnabled() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_soundEnabledKey) ?? true;
  }

  Future<void> saveSoundEnabled(bool enabled) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_soundEnabledKey, enabled);
  }

  Future<double> loadVolume() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(_volumeKey) ?? 0.8;
  }

  Future<void> saveVolume(double volume) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setDouble(_volumeKey, volume);
  }
}