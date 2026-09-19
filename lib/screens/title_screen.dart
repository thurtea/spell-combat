import 'package:flutter/material.dart';

import '../audio/audio_service.dart';
import '../models/difficulty.dart';
import '../services/settings_service.dart';
import '../widgets/difficulty_selector.dart';
import 'battle_screen.dart';
import 'settings_screen.dart';

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final _settings = SettingsService();
  Difficulty _difficulty = Difficulty.normal;

  @override
  void initState() {
    super.initState();
    _loadDifficulty();
    _loadAudioSettings();
  }

  Future<void> _loadDifficulty() async {
    final difficulty = await _settings.loadDifficulty();
    if (mounted) setState(() => _difficulty = difficulty);
  }

  Future<void> _loadAudioSettings() async {
    AudioService.instance.enabled = await _settings.loadSoundEnabled();
    AudioService.instance.volume = await _settings.loadVolume();
  }

  Future<void> _setDifficulty(Difficulty difficulty) async {
    AudioService.instance.buttonClick();
    setState(() => _difficulty = difficulty);
    await _settings.saveDifficulty(difficulty);
  }

  void _startGame() {
    AudioService.instance.buttonClick();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BattleScreen(difficulty: _difficulty),
      ),
    );
  }

  void _openSettings() {
    AudioService.instance.buttonClick();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 720;
            final horizontalPadding = wide ? 72.0 : 24.0;
            final content = SizedBox(
              width: constraints.maxWidth - horizontalPadding * 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 980),
                child: Flex(
                    direction: wide ? Axis.horizontal : Axis.vertical,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: wide
                        ? [
                            Expanded(
                              flex: 5,
                              child: _BrandPanel(colors: colors, wide: wide),
                            ),
                            const SizedBox(width: 56),
                            Expanded(
                              flex: 4,
                              child: _ActionPanel(
                                difficulty: _difficulty,
                                onDifficultyChanged: _setDifficulty,
                                onStart: _startGame,
                                onSettings: _openSettings,
                              ),
                            ),
                          ]
                        : [
                            _BrandPanel(colors: colors, wide: wide),
                            const SizedBox(height: 32),
                            _ActionPanel(
                              difficulty: _difficulty,
                              onDifficultyChanged: _setDifficulty,
                              onStart: _startGame,
                              onSettings: _openSettings,
                            ),
                          ],
                ),
              ),
            );
            if (wide) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: content,
                ),
              );
            }
            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 28),
                child: content,
              ),
            );
          },
        ),
      ),
    );
  }
}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel({required this.colors, required this.wide});

  final ColorScheme colors;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final iconSize = wide ? 54.0 : 44.0;
    final displayStyle = Theme.of(context).textTheme.displayMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: iconSize * 2.2,
          height: iconSize * 2.2,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: iconSize * 2.2,
                height: iconSize * 2.2,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colors.tertiary.withValues(alpha: 0.35),
                      colors.tertiary.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
              Icon(Icons.local_fire_department_rounded, size: iconSize, color: colors.primary),
            ],
          ),
        ),
        const SizedBox(height: 22),
        RichText(
          text: TextSpan(
            style: displayStyle,
            children: [
              TextSpan(text: 'SPELL\n', style: TextStyle(color: colors.secondary)),
              TextSpan(text: 'COMBAT', style: TextStyle(color: colors.primary)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Build words. Break monsters.\nEvery letter has a price.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colors.onSurfaceVariant),
        ),
        const SizedBox(height: 34),
        Row(
          children: [
            Icon(Icons.flash_on_rounded, size: 18, color: colors.tertiary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'TURN-BASED WORD COMBAT',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionPanel extends StatelessWidget {
  const _ActionPanel({
    required this.difficulty,
    required this.onDifficultyChanged,
    required this.onStart,
    required this.onSettings,
  });

  final Difficulty difficulty;
  final ValueChanged<Difficulty> onDifficultyChanged;
  final VoidCallback onStart;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SELECT DIFFICULTY', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 12),
          DifficultySelector(value: difficulty, onChanged: onDifficultyChanged),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onStart,
            icon: const Icon(Icons.flash_on_rounded),
            label: const Text('START GAME'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onSettings,
            icon: const Icon(Icons.tune_rounded),
            label: const Text('SETTINGS'),
          ),
        ],
      ),
    );
  }
}