import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../audio/audio_service.dart';
import '../data/enemy_roster.dart';
import '../models/difficulty.dart';
import '../models/enemy_archetype.dart';
import '../models/game_state.dart';
import '../models/letter_tile.dart';
import '../services/battle_controller.dart';
import '../theme/spell_colors.dart';
import '../widgets/hp_bar.dart';
import '../widgets/letter_tile_widget.dart';

class BattleScreen extends StatefulWidget {
  const BattleScreen({required this.difficulty, super.key});

  final Difficulty difficulty;

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  late final BattleController _controller;
  late EnemyDefinition _enemyDefinition;
  final FocusNode _focusNode = FocusNode(debugLabel: 'BattleScreenShortcuts');

  late int _lastEnemyHp;
  late int _lastPlayerHp;
  late GameState _lastGameState;
  int _enemyHitTick = 0;
  int _playerHitTick = 0;
  Timer? _enemyTurnTimer;
  Timer? _enemyAttackTimer;

  @override
  void initState() {
    super.initState();
    _controller = BattleController(difficulty: widget.difficulty);
    _enemyDefinition = EnemyRoster.forDifficulty(widget.difficulty);
    _lastEnemyHp = _controller.state.enemy.hp;
    _lastPlayerHp = _controller.state.player.hp;
    _lastGameState = _controller.state.gameState;
    _controller.addListener(_handleControllerChange);
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChange);
    _controller.dispose();
    _enemyTurnTimer?.cancel();
    _enemyAttackTimer?.cancel();
    _focusNode.dispose();
    super.dispose();
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.numpadEnter) {
      _submitWord();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _clearWord();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _handleControllerChange() {
    final state = _controller.state;

    if (state.enemy.hp < _lastEnemyHp) {
      AudioService.instance.hitEnemy();
      setState(() => _enemyHitTick++);
    }
    if (state.player.hp < _lastPlayerHp) {
      AudioService.instance.hitPlayer();
      setState(() => _playerHitTick++);
    }
    if (state.gameState == GameState.enemyTurn && _lastGameState == GameState.playerTurn) {
      _scheduleEnemyTurn();
    }
    if (state.gameState == GameState.victory && _lastGameState != GameState.victory) {
      AudioService.instance.victory();
    }
    if (state.gameState == GameState.defeat && _lastGameState != GameState.defeat) {
      AudioService.instance.defeat();
    }

    _lastEnemyHp = state.enemy.hp;
    _lastPlayerHp = state.player.hp;
    _lastGameState = state.gameState;
    setState(() {});
  }

  void _scheduleEnemyTurn() {
    _enemyTurnTimer?.cancel();
    _enemyTurnTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      AudioService.instance.enemyTurn();
      _enemyAttackTimer?.cancel();
      _enemyAttackTimer = Timer(const Duration(milliseconds: 550), () {
        if (!mounted) return;
        _controller.enemyTurn();
      });
    });
  }

  void _selectLetter(LetterTile tile) {
    if (tile.isSelected) {
      _controller.deselectLetter(tile.id);
      AudioService.instance.letterDeselect();
    } else {
      _controller.selectLetter(tile.id);
      AudioService.instance.letterSelect();
    }
  }

  void _clearWord() {
    if (_controller.state.gameState != GameState.playerTurn) return;
    if (_controller.state.currentWord.isEmpty) return;
    AudioService.instance.buttonClick();
    _controller.clearWord();
  }

  void _shuffleHand() {
    final didShuffle = _controller.shuffleHand();
    if (didShuffle) {
      AudioService.instance.shuffle();
    } else {
      AudioService.instance.wordInvalid();
    }
  }

  void _rerollTile(LetterTile tile) {
    final didReroll = _controller.rerollTile(tile.id);
    if (didReroll) {
      AudioService.instance.shuffle();
    } else {
      AudioService.instance.wordInvalid();
    }
  }

  void _submitWord() {
    if (_controller.state.gameState != GameState.playerTurn) return;
    if (_controller.state.currentWord.isEmpty) return;
    final success = _controller.submitWord();
    if (success) {
      AudioService.instance.wordCast();
    } else {
      AudioService.instance.wordInvalid();
    }
  }

  void _usePowerWord() {
    final success = _controller.usePowerWord();
    if (success) {
      AudioService.instance.powerWord();
    } else {
      AudioService.instance.wordInvalid();
    }
  }

  void _restartBattle() {
    AudioService.instance.buttonClick();
    setState(() {
      _controller.resetBattle();
      _lastEnemyHp = _controller.state.enemy.hp;
      _lastPlayerHp = _controller.state.player.hp;
      _lastGameState = _controller.state.gameState;
    });
  }

  void _returnToMenu() {
    AudioService.instance.buttonClick();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;
    final colors = Theme.of(context).colorScheme;
    final isPlayerTurn = state.gameState == GameState.playerTurn;
    final isBattleOver =
        state.gameState == GameState.victory || state.gameState == GameState.defeat;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 48,
        title: Text('${widget.difficulty.label} Battle'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                'Turn ${state.turnNumber}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Focus(
          focusNode: _focusNode,
          autofocus: true,
          onKeyEvent: _handleKeyEvent,
          child: Stack(
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.2,
                    colors: [
                      Color.alphaBlend(SpellColors.mystic.withValues(alpha: 0.10), colors.surface),
                      Theme.of(context).scaffoldBackgroundColor,
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: _EnemyPanel(
                              definition: _enemyDefinition,
                              hp: state.enemy.hp,
                              maxHp: state.enemy.maxHp,
                              hitTick: _enemyHitTick,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _TurnBanner(gameState: state.gameState),
                          const SizedBox(height: 6),
                          _PlayerPanel(
                            hp: state.player.hp,
                            maxHp: state.player.maxHp,
                            comboCount: state.comboCount,
                            hitTick: _playerHitTick,
                          ),
                          const SizedBox(height: 8),
                          _WordBuilder(word: state.currentWord.text),
                          const SizedBox(height: 8),
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 8,
                            runSpacing: 8,
                            children: state.currentHand
                                .map(
                                  (tile) => LetterTileWidget(
                                    tile: tile,
                                    onTap: isPlayerTurn ? () => _selectLetter(tile) : () {},
                                    onLongPress: isPlayerTurn && state.rerollCharges > 0
                                        ? () => _rerollTile(tile)
                                        : null,
                                  ),
                                )
                                .toList(),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/keyboard.svg',
                                width: 14,
                                height: 14,
                                colorFilter:
                                    ColorFilter.mode(colors.onSurfaceVariant, BlendMode.srcIn),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Tap to spell, hold to reroll · Enter casts, Esc clears',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: colors.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _ActionRow(
                            isPlayerTurn: isPlayerTurn,
                            wordReady: !state.currentWord.isEmpty,
                            shuffleCharges: state.shuffleCharges,
                            powerWordReady: state.powerWordReady,
                            difficulty: state.difficulty,
                            onClear: _clearWord,
                            onShuffle: state.shuffleCharges > 0 ? _shuffleHand : null,
                            onSubmit: _submitWord,
                            onPowerWord: _usePowerWord,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              if (isBattleOver)
                _ResultOverlay(
                  victory: state.gameState == GameState.victory,
                  enemyName: _enemyDefinition.enemy.name,
                  onPlayAgain: _restartBattle,
                  onReturnToMenu: _returnToMenu,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnemyPanel extends StatelessWidget {
  const _EnemyPanel({
    required this.definition,
    required this.hp,
    required this.maxHp,
    required this.hitTick,
  });

  final EnemyDefinition definition;
  final int hp;
  final int maxHp;
  final int hitTick;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              SvgPicture.asset(
                definition.badgeIcon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      definition.enemy.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      definition.enemy.archetype.label,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Expanded(
            child: KeyedSubtree(
              key: ValueKey(hitTick),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      SpellColors.mystic.withValues(alpha: 0.28),
                      SpellColors.mystic.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Image.asset(
                  definition.spriteForHp(hp, maxHp),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                ).animate().shake(hz: 5, offset: const Offset(0.02, 0)),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            definition.tagline,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colors.onSurfaceVariant),
          ),
          const SizedBox(height: 6),
          HpBar(hp: hp, maxHp: maxHp, color: SpellColors.ember),
        ],
      ),
    );
  }
}

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({
    required this.hp,
    required this.maxHp,
    required this.comboCount,
    required this.hitTick,
  });

  final int hp;
  final int maxHp;
  final int comboCount;
  final int hitTick;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
      ),
      child: KeyedSubtree(
        key: ValueKey(hitTick),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/sword.svg',
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(colors.primary, BlendMode.srcIn),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Spellcaster', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  HpBar(hp: hp, maxHp: maxHp, color: SpellColors.arcane),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  'assets/icons/fire.svg',
                  width: 18,
                  height: 18,
                  colorFilter: const ColorFilter.mode(SpellColors.ember, BlendMode.srcIn),
                ),
                Text('x$comboCount', style: Theme.of(context).textTheme.labelMedium),
              ],
            ),
          ],
        ),
      ).animate().shake(hz: 5, offset: const Offset(0.02, 0)),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.gameState});

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final label = switch (gameState) {
      GameState.playerTurn => 'YOUR TURN - cast a word',
      GameState.enemyTurn => 'ENEMY TURN...',
      GameState.victory => 'VICTORY',
      GameState.defeat => 'DEFEATED',
      GameState.menu => '',
    };
    return Center(
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: gameState == GameState.playerTurn ? colors.secondary : colors.primary,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}

class _WordBuilder extends StatelessWidget {
  const _WordBuilder({required this.word});

  final String word;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: word.isEmpty ? colors.outlineVariant : colors.secondary),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        word.isEmpty ? '-' : word,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              letterSpacing: 3,
              color: word.isEmpty ? colors.onSurfaceVariant : colors.secondary,
            ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isPlayerTurn,
    required this.wordReady,
    required this.shuffleCharges,
    required this.powerWordReady,
    required this.difficulty,
    required this.onClear,
    required this.onShuffle,
    required this.onSubmit,
    required this.onPowerWord,
  });

  final bool isPlayerTurn;
  final bool wordReady;
  final int shuffleCharges;
  final bool powerWordReady;
  final Difficulty difficulty;
  final VoidCallback onClear;
  final VoidCallback? onShuffle;
  final VoidCallback onSubmit;
  final VoidCallback onPowerWord;

  @override
  Widget build(BuildContext context) {
    final showManualPowerWord = difficulty != Difficulty.easy && powerWordReady;
    const compactPadding = EdgeInsets.symmetric(vertical: 10);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: compactPadding),
                onPressed: isPlayerTurn ? onClear : null,
                icon: const Icon(Icons.backspace_outlined),
                label: const Text('CLEAR'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(padding: compactPadding),
                onPressed: isPlayerTurn ? onShuffle : null,
                icon: const Icon(Icons.shuffle_rounded),
                label: Text('SHUFFLE ($shuffleCharges)'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        FilledButton.icon(
          style: FilledButton.styleFrom(padding: compactPadding),
          onPressed: isPlayerTurn && wordReady ? onSubmit : null,
          icon: const Icon(Icons.flash_on_rounded),
          label: const Text('CAST WORD'),
        ),
        if (showManualPowerWord) ...[
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: SpellColors.mystic,
              padding: compactPadding,
            ),
            onPressed: isPlayerTurn ? onPowerWord : null,
            icon: SvgPicture.asset(
              'assets/icons/lightning.svg',
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
            label: const Text('POWER WORD'),
          ),
        ] else if (difficulty == Difficulty.easy) ...[
          const SizedBox(height: 6),
          Text(
            'Power Word auto-casts once your combo hits 5x',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ],
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  const _ResultOverlay({
    required this.victory,
    required this.enemyName,
    required this.onPlayAgain,
    required this.onReturnToMenu,
  });

  final bool victory;
  final String enemyName;
  final VoidCallback onPlayAgain;
  final VoidCallback onReturnToMenu;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.82),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  victory ? Icons.emoji_events_rounded : Icons.heart_broken_rounded,
                  size: 72,
                  color: victory ? SpellColors.gold : colors.primary,
                ).animate().scale(duration: 420.ms, curve: Curves.elasticOut),
                const SizedBox(height: 18),
                Text(
                  victory ? 'VICTORY!' : 'DEFEATED',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 10),
                Text(
                  victory
                      ? 'You have vanquished the $enemyName.'
                      : 'The $enemyName has overwhelmed you.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 260,
                  child: FilledButton.icon(
                    onPressed: onPlayAgain,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('PLAY AGAIN'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 260,
                  child: OutlinedButton.icon(
                    onPressed: onReturnToMenu,
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('RETURN TO MENU'),
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
