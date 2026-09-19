import 'difficulty.dart';
import 'enemy.dart';
import 'game_state.dart';
import 'letter_tile.dart';
import 'player.dart';
import 'word.dart';

class BattleState {
  const BattleState({
    required this.player,
    required this.enemy,
    required this.currentHand,
    required this.currentWord,
    required this.comboCount,
    required this.turnNumber,
    required this.difficulty,
    this.gameState = GameState.playerTurn,
    this.powerWordReady = false,
    this.shuffleCharges = 0,
    this.rerollCharges = 0,
  });

  final Player player;
  final Enemy enemy;
  final List<LetterTile> currentHand;
  final Word currentWord;
  final int comboCount;
  final int turnNumber;
  final Difficulty difficulty;
  final GameState gameState;
  final bool powerWordReady;
  final int shuffleCharges;
  final int rerollCharges;

  BattleState copyWith({
    Player? player,
    Enemy? enemy,
    List<LetterTile>? currentHand,
    Word? currentWord,
    int? comboCount,
    int? turnNumber,
    Difficulty? difficulty,
    GameState? gameState,
    bool? powerWordReady,
    int? shuffleCharges,
    int? rerollCharges,
  }) {
    return BattleState(
      player: player ?? this.player,
      enemy: enemy ?? this.enemy,
      currentHand: List.unmodifiable(currentHand ?? this.currentHand),
      currentWord: currentWord ?? this.currentWord,
      comboCount: comboCount ?? this.comboCount,
      turnNumber: turnNumber ?? this.turnNumber,
      difficulty: difficulty ?? this.difficulty,
      gameState: gameState ?? this.gameState,
      powerWordReady: powerWordReady ?? this.powerWordReady,
      shuffleCharges: shuffleCharges ?? this.shuffleCharges,
      rerollCharges: rerollCharges ?? this.rerollCharges,
    );
  }
}