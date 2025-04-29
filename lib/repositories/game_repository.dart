import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';
import '../models/game_data_model.dart';
import 'base_repository.dart';

/// Repository for handling game data in Firestore
class GameRepository extends BaseRepository<GameDataModel> {
  // Singleton pattern
  static GameRepository? _instance;
  static GameRepository get instance => _instance ??= GameRepository._();

  GameRepository._() : super('games');

  @override
  GameDataModel fromFirestore(DocumentSnapshot doc) {
    return GameDataModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(GameDataModel model) {
    return model.toMap();
  }

  // Create a new game
  Future<String> createGame(String redPlayerId, String blackPlayerId, {
    bool isRanked = true,
    int? tournamentId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final gameModel = GameDataModel(
        id: '', // Will be set by Firestore
        redPlayerId: redPlayerId,
        blackPlayerId: blackPlayerId,
        finalFen: '', // Initial empty FEN
        redTimeRemaining: 180, // 3 minutes in seconds
        blackTimeRemaining: 180, // 3 minutes in seconds
        startedAt: Timestamp.now(),
        isRanked: isRanked,
        tournamentId: tournamentId,
        metadata: metadata,
      );

      final gameId = await add(gameModel);
      logger.info('Game created: $gameId');
      return gameId;
    } catch (e) {
      logger.severe('Error creating game: $e');
      rethrow;
    }
  }

  // End a game
  Future<void> endGame(String gameId, {
    String? winnerId,
    bool isDraw = false,
    required String finalFen,
    required int redTimeRemaining,
    required int blackTimeRemaining,
    required List<String> moves,
  }) async {
    try {
      final updates = {
        'winnerId': winnerId,
        'isDraw': isDraw,
        'finalFen': finalFen,
        'redTimeRemaining': redTimeRemaining,
        'blackTimeRemaining': blackTimeRemaining,
        'moveCount': moves.length,
        'moves': moves,
        'endedAt': Timestamp.now(),
      };

      await update(gameId, updates);
      logger.info('Game ended: $gameId');
    } catch (e) {
      logger.severe('Error ending game: $e');
      rethrow;
    }
  }

  // Add a move to a game
  Future<void> addMove(String gameId, String move) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final gameDoc = await transaction.get(collection.doc(gameId));
        
        if (!gameDoc.exists) return;
        
        final gameData = gameDoc.data() as Map<String, dynamic>;
        final List<String> moves = List<String>.from(gameData['moves'] ?? []);
        
        moves.add(move);
        
        transaction.update(collection.doc(gameId), {
          'moves': moves,
          'moveCount': moves.length,
        });
      });
      
      logger.info('Move added to game: $gameId');
    } catch (e) {
      logger.severe('Error adding move to game: $e');
      rethrow;
    }
  }

  // Update time remaining
  Future<void> updateTimeRemaining(String gameId, int redTimeRemaining, int blackTimeRemaining) async {
    try {
      await update(gameId, {
        'redTimeRemaining': redTimeRemaining,
        'blackTimeRemaining': blackTimeRemaining,
      });
    } catch (e) {
      logger.severe('Error updating time remaining: $e');
      rethrow;
    }
  }

  // Get games by player
  Future<List<GameDataModel>> getGamesByPlayer(String playerId, {int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .where(Filter.or(
            Filter('redPlayerId', isEqualTo: playerId),
            Filter('blackPlayerId', isEqualTo: playerId),
          ))
          .orderBy('startedAt', descending: true)
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting games by player: $e');
      rethrow;
    }
  }

  // Get games by tournament
  Future<List<GameDataModel>> getGamesByTournament(int tournamentId) async {
    try {
      return await query((collection) => 
        collection
          .where('tournamentId', isEqualTo: tournamentId)
          .orderBy('startedAt', descending: true)
      );
    } catch (e) {
      logger.severe('Error getting games by tournament: $e');
      rethrow;
    }
  }

  // Get active games by player
  Future<List<GameDataModel>> getActiveGamesByPlayer(String playerId) async {
    try {
      return await query((collection) => 
        collection
          .where(Filter.or(
            Filter('redPlayerId', isEqualTo: playerId),
            Filter('blackPlayerId', isEqualTo: playerId),
          ))
          .where('endedAt', isNull: true)
          .orderBy('startedAt', descending: true)
      );
    } catch (e) {
      logger.severe('Error getting active games by player: $e');
      rethrow;
    }
  }

  // Listen to active game
  Stream<GameDataModel?> listenToActiveGame(String gameId) {
    return listen(gameId);
  }
}
