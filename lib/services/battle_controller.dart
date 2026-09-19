import 'package:flutter/foundation.dart';

import '../data/enemy_roster.dart';
import '../models/battle_state.dart';
import '../models/difficulty.dart';
import '../models/enemy.dart';
import '../models/enemy_archetype.dart';
import '../models/game_state.dart';
import '../models/letter_tile.dart';
import '../models/player.dart';
import '../models/word.dart';
import 'archetypes/enemy_archetype_hook.dart';
import 'archetypes/enemy_archetype_hooks.dart';
import 'damage_calculator.dart';
import 'letter_generator.dart';
import 'word_validator.dart';

class BattleController extends ChangeNotifier {
  BattleController({
    required Difficulty difficulty,
    Player? player,
    Enemy? enemy,
    LetterGenerator? letterGenerator,
    WordValidator? wordValidator,
    DamageCalculator? damageCalculator,
  })  : _letterGenerator = letterGenerator ?? LetterGenerator(),
        _wordValidator = wordValidator ?? WordValidator(),
        _damageCalculator = damageCalculator ?? const DamageCalculator(),
        _hooks = createEnemyArchetypeHooks() {
    final startingPlayer = player ?? const Player(name: 'Spellcaster', hp: 100, maxHp: 100);
    // Default to Goblin Scout unless a caller supplies a specific foe.
    final startingEnemy = enemy ?? EnemyRoster.starting().enemy;
    _state = BattleState(
      player: startingPlayer,
      enemy: startingEnemy,
      currentHand: _letterGenerator.generateHand(difficulty),
      currentWord: const Word(),
      comboCount: 0,
      turnNumber: 1,
      difficulty: difficulty,
      shuffleCharges: _shuffleChargesFor(difficulty),
      rerollCharges: _rerollChargesFor(difficulty),
    );
  }

  static int _shuffleChargesFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 3,
        Difficulty.normal => 2,
        Difficulty.hard => 1,
      };

  static int _rerollChargesFor(Difficulty difficulty) => switch (difficulty) {
        Difficulty.easy => 4,
        Difficulty.normal => 3,
        Difficulty.hard => 1,
      };

  final LetterGenerator _letterGenerator;
  final WordValidator _wordValidator;
  final DamageCalculator _damageCalculator;
  final Map<EnemyArchetype, EnemyArchetypeHook> _hooks;
  late BattleState _state;

  BattleState get state => _state;

  EnemyArchetypeHook get _activeHook => _hooks[_state.enemy.archetype]!;

  void selectLetter(String tileId) {
    if (_state.gameState != GameState.playerTurn) return;
    final tileIndex = _state.currentHand.indexWhere((tile) => tile.id == tileId);
    if (tileIndex < 0 || _state.currentHand[tileIndex].isSelected) return;

    final updatedHand = [..._state.currentHand];
    final selectedTile = updatedHand[tileIndex].copyWith(isSelected: true);
    updatedHand[tileIndex] = selectedTile;
    _update(
      currentHand: updatedHand,
      currentWord: Word(
        text: '${_state.currentWord.text}${selectedTile.letter}',
        tileIds: [..._state.currentWord.tileIds, selectedTile.id],
      ),
    );
  }

  void deselectLetter(String tileId) {
    if (_state.gameState != GameState.playerTurn) return;
    final tileIndex = _state.currentHand.indexWhere((tile) => tile.id == tileId);
    if (tileIndex < 0 || !_state.currentHand[tileIndex].isSelected) return;

    final updatedHand = [..._state.currentHand];
    updatedHand[tileIndex] = updatedHand[tileIndex].copyWith(isSelected: false);
    final updatedTileIds = [..._state.currentWord.tileIds]..remove(tileId);
    final updatedText = updatedTileIds
        .map((id) => _state.currentHand.firstWhere((tile) => tile.id == id).letter)
        .join();
    _update(
      currentHand: updatedHand,
      currentWord: Word(text: updatedText, tileIds: updatedTileIds),
    );
  }

  void clearWord() {
    if (_state.gameState != GameState.playerTurn) return;
    _update(
      currentHand: _state.currentHand
          .map((tile) => tile.copyWith(isSelected: false))
          .toList(),
      currentWord: const Word(),
      comboCount: 0,
    );
  }

  bool shuffleHand() {
    if (_state.gameState != GameState.playerTurn) return false;
    if (_state.shuffleCharges <= 0) return false;

    final freshHand = _letterGenerator.generateHand(_state.difficulty);
    _update(
      currentHand: freshHand,
      currentWord: const Word(),
      shuffleCharges: _state.shuffleCharges - 1,
    );
    return true;
  }

  bool rerollTile(String tileId) {
    if (_state.gameState != GameState.playerTurn) return false;
    if (_state.rerollCharges <= 0) return false;

    final tileIndex = _state.currentHand.indexWhere((tile) => tile.id == tileId);
    if (tileIndex < 0) return false;

    final wasSelected = _state.currentHand[tileIndex].isSelected;
    final updatedHand = [..._state.currentHand];
    updatedHand[tileIndex] = _letterGenerator.generateTile();

    final updatedTileIds = wasSelected
        ? ([..._state.currentWord.tileIds]..remove(tileId))
        : _state.currentWord.tileIds;
    final updatedText = updatedTileIds
        .map((id) => updatedHand.firstWhere((tile) => tile.id == id).letter)
        .join();

    _update(
      currentHand: updatedHand,
      currentWord: Word(text: updatedText, tileIds: updatedTileIds),
      rerollCharges: _state.rerollCharges - 1,
    );
    return true;
  }

  bool submitWord() {
    final powerWordActive = _state.difficulty == Difficulty.easy &&
        _state.comboCount >= DamageConstants.highComboThreshold;
    return _submitWord(isPowerWord: powerWordActive);
  }

  bool usePowerWord() {
    if (_state.difficulty == Difficulty.easy || !_state.powerWordReady) {
      return false;
    }
    return _submitWord(isPowerWord: true);
  }

  bool _submitWord({required bool isPowerWord}) {
    if (_state.gameState != GameState.playerTurn) return false;
    if (!isPowerWord && !_wordValidator.isValid(
      word: _state.currentWord.text,
      currentHand: _state.currentHand,
    )) {
      clearWord();
      return false;
    }

    final usedTiles = isPowerWord ? _state.currentHand : _selectedTiles;
    final damage = _damageCalculator.calculateDamage(
      usedTiles: usedTiles,
      currentHand: _state.currentHand,
      comboCount: _state.comboCount + 1,
      isPowerWord: isPowerWord,
    );
    final modifiedDamage = _activeHook.modifyIncomingDamage(
      damage: damage,
      wordLength: usedTiles.length,
    );
    final remainingHp = (_state.enemy.hp - modifiedDamage).clamp(0, _state.enemy.maxHp);
    _activeHook.onPlayerWordSubmitted(usedTiles);
    final updatedEnemy = _state.enemy.copyWith(hp: remainingHp);
    final nextCombo = _state.comboCount + 1;
    final nextState = updatedEnemy.hp == 0 ? GameState.victory : GameState.enemyTurn;

    _update(
      enemy: updatedEnemy,
      currentHand: _refillHand(usedTiles),
      currentWord: const Word(),
      comboCount: isPowerWord ? 0 : nextCombo,
      turnNumber: _state.turnNumber + 1,
      gameState: nextState,
      powerWordReady: !isPowerWord && nextCombo >= DamageConstants.highComboThreshold,
    );
    return true;
  }

  void enemyTurn() {
    if (_state.gameState != GameState.enemyTurn) return;
    final updatedHand = _activeHook.onEnemyTurnStart(
      currentHand: _state.currentHand,
      letterGenerator: _letterGenerator,
    );
    final enemyAttack = _activeHook.enemyAttackPower(enemy: _state.enemy) +
        _activeHook.consumeAdditionalAttackPower();
    final remainingHp = (_state.player.hp - enemyAttack).clamp(0, _state.player.maxHp);
    _update(
      player: _state.player.copyWith(hp: remainingHp),
      currentHand: updatedHand,
      gameState: remainingHp == 0 ? GameState.defeat : GameState.playerTurn,
    );
  }

  void resetBattle({Difficulty? difficulty, Player? player, Enemy? enemy}) {
    final nextDifficulty = difficulty ?? _state.difficulty;
    _state = BattleState(
      player: player ?? const Player(name: 'Spellcaster', hp: 100, maxHp: 100),
      enemy: enemy ?? EnemyRoster.starting().enemy,
      currentHand: _letterGenerator.generateHand(nextDifficulty),
      currentWord: const Word(),
      comboCount: 0,
      turnNumber: 1,
      difficulty: nextDifficulty,
      shuffleCharges: _shuffleChargesFor(nextDifficulty),
      rerollCharges: _rerollChargesFor(nextDifficulty),
    );
    notifyListeners();
  }

  List<LetterTile> get _selectedTiles => _state.currentHand
      .where((tile) => _state.currentWord.tileIds.contains(tile.id))
      .toList();

  List<LetterTile> _refillHand(List<LetterTile> removedTiles) {
    final removedIds = removedTiles.map((tile) => tile.id).toSet();
    final remainingHand = _state.currentHand
        .where((tile) => !removedIds.contains(tile.id))
        .map((tile) => tile.copyWith(isSelected: false))
        .toList();
    while (remainingHand.length < _state.currentHand.length) {
      remainingHand.add(_letterGenerator.generateTile());
    }
    return remainingHand;
  }

  void _update({
    Player? player,
    Enemy? enemy,
    List<LetterTile>? currentHand,
    Word? currentWord,
    int? comboCount,
    int? turnNumber,
    GameState? gameState,
    bool? powerWordReady,
    int? shuffleCharges,
    int? rerollCharges,
  }) {
    _state = _state.copyWith(
      player: player,
      enemy: enemy,
      currentHand: currentHand,
      currentWord: currentWord,
      comboCount: comboCount,
      turnNumber: turnNumber,
      gameState: gameState,
      powerWordReady: powerWordReady,
      shuffleCharges: shuffleCharges,
      rerollCharges: rerollCharges,
    );
    notifyListeners();
  }
}