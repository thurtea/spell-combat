import 'package:flutter/material.dart';

import '../audio/audio_service.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsService();
  bool _soundEnabled = true;
  double _volume = 0.8;
  bool _musicEnabled = true;
  double _musicVolume = 0.5;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await _settings.loadSoundEnabled();
    final volume = await _settings.loadVolume();
    final musicEnabled = await _settings.loadMusicEnabled();
    final musicVolume = await _settings.loadMusicVolume();
    if (!mounted) return;
    setState(() {
      _soundEnabled = enabled;
      _volume = volume;
      _musicEnabled = musicEnabled;
      _musicVolume = musicVolume;
      _loaded = true;
      AudioService.instance.enabled = enabled;
      AudioService.instance.volume = volume;
      AudioService.instance.musicEnabled = musicEnabled;
      AudioService.instance.musicVolume = musicVolume;
    });
  }

  Future<void> _toggleSound(bool enabled) async {
    setState(() => _soundEnabled = enabled);
    AudioService.instance.enabled = enabled;
    await _settings.saveSoundEnabled(enabled);
    if (enabled) AudioService.instance.buttonClick();
  }

  Future<void> _changeVolume(double volume) async {
    setState(() => _volume = volume);
    AudioService.instance.volume = volume;
    await _settings.saveVolume(volume);
  }

  Future<void> _toggleMusic(bool enabled) async {
    setState(() => _musicEnabled = enabled);
    await AudioService.instance.setMusicEnabled(enabled);
    await _settings.saveMusicEnabled(enabled);
  }

  Future<void> _changeMusicVolume(double volume) async {
    setState(() => _musicVolume = volume);
    await AudioService.instance.setMusicVolume(volume);
    await _settings.saveMusicVolume(volume);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text('AUDIO', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Sound effects'),
                              subtitle: const Text('Button taps, spells, hits, victory and defeat cues'),
                              value: _soundEnabled,
                              onChanged: _toggleSound,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.volume_down_rounded, color: colors.onSurfaceVariant),
                                Expanded(
                                  child: Slider(
                                    value: _volume,
                                    onChanged: _soundEnabled ? _changeVolume : null,
                                    onChangeEnd: (_) => AudioService.instance.buttonClick(),
                                  ),
                                ),
                                Icon(Icons.volume_up_rounded, color: colors.onSurfaceVariant),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('MUSIC', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SwitchListTile(
                              contentPadding: EdgeInsets.zero,
                              title: const Text('Background music'),
                              subtitle: const Text('Menu and battle music loops'),
                              value: _musicEnabled,
                              onChanged: _toggleMusic,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.music_note_rounded, color: colors.onSurfaceVariant),
                                Expanded(
                                  child: Slider(
                                    value: _musicVolume,
                                    onChanged: _musicEnabled ? _changeMusicVolume : null,
                                  ),
                                ),
                                Icon(Icons.music_note_rounded, color: colors.onSurfaceVariant),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('HOW TO PLAY', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: colors.surface,
                          border: Border.all(color: colors.outlineVariant),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _HowToPlayLine(
                              icon: Icons.grid_view_rounded,
                              text: 'Tap letter tiles to build a real word from your hand.',
                            ),
                            SizedBox(height: 12),
                            _HowToPlayLine(
                              icon: Icons.flash_on_rounded,
                              text: 'Submit the word to cast a spell and damage the enemy. '
                                  'Longer words and full-hand "bingos" hit harder.',
                            ),
                            SizedBox(height: 12),
                            _HowToPlayLine(
                              icon: Icons.local_fire_department_rounded,
                              text: 'Chain valid words to build combo multipliers and '
                                  'unlock a devastating Power Word.',
                            ),
                            SizedBox(height: 12),
                            _HowToPlayLine(
                              icon: Icons.shuffle_rounded,
                              text: 'Stuck with a bad hand? Spend a shuffle or reroll charge.',
                            ),
                            SizedBox(height: 12),
                            _HowToPlayLine(
                              icon: Icons.shield_moon_rounded,
                              text: 'Every enemy archetype fights differently: shields, vowel '
                                  'theft, and berserker rage all change your strategy.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _HowToPlayLine extends StatelessWidget {
  const _HowToPlayLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}
