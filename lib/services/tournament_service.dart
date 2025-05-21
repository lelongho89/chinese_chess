import '../global.dart';
import '../models/match_model.dart';
import '../models/tournament_model.dart';
import '../repositories/match_repository.dart';
import '../repositories/tournament_repository.dart';
import 'game_service.dart';

/// Service for handling tournament operations
class TournamentService {
  // Singleton pattern
  static TournamentService? _instance;
  static TournamentService get instance => _instance ??= TournamentService._();

  TournamentService._();

  // Create a new tournament
  Future<String> createTournament({
    required String name,
    required String description,
    required String creatorId,
    required int maxParticipants,
    required DateTime startTime,
    TournamentType type = TournamentType.singleElimination,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tournamentId = await TournamentRepository.instance.createTournament(
        name: name,
        description: description,
        creatorId: creatorId,
        maxParticipants: maxParticipants,
        startTime: startTime,
        type: type,
        settings: settings,
        metadata: metadata,
      );

      logger.info('Tournament created: $tournamentId');
      return tournamentId;
    } catch (e) {
      logger.severe('Error creating tournament: $e');
      rethrow;
    }
  }

  // Register a player for a tournament
  Future<void> registerPlayer(String tournamentId, String playerId) async {
    try {
      await TournamentRepository.instance.addParticipant(tournamentId, playerId);
      logger.info('Player registered for tournament: $tournamentId -> $playerId');
    } catch (e) {
      logger.severe('Error registering player for tournament: $e');
      rethrow;
    }
  }

  // Unregister a player from a tournament
  Future<void> unregisterPlayer(String tournamentId, String playerId) async {
    try {
      await TournamentRepository.instance.removeParticipant(tournamentId, playerId);
      logger.info('Player unregistered from tournament: $tournamentId -> $playerId');
    } catch (e) {
      logger.severe('Error unregistering player from tournament: $e');
      rethrow;
    }
  }

  // Start a tournament
  Future<void> startTournament(String tournamentId) async {
    try {
      // Get the tournament
      final tournament = await TournamentRepository.instance.get(tournamentId);

      if (tournament == null) {
        throw Exception('Tournament not found');
      }

      // Check if tournament has enough participants
      if (tournament.participantIds.length < 2) {
        throw Exception('Tournament needs at least 2 participants');
      }

      // Update tournament status
      await TournamentRepository.instance.updateStatus(tournamentId, TournamentStatus.inProgress);

      // Generate matches based on tournament type
      await _generateMatches(tournament);

      logger.info('Tournament started: $tournamentId');
    } catch (e) {
      logger.severe('Error starting tournament: $e');
      rethrow;
    }
  }

  // Generate matches for a tournament
  Future<void> _generateMatches(TournamentModel tournament) async {
    try {
      switch (tournament.type) {
        case TournamentType.singleElimination:
          await _generateSingleEliminationMatches(tournament);
          break;
        case TournamentType.doubleElimination:
          // Not implemented yet
          throw UnimplementedError('Double elimination tournaments are not implemented yet');
        case TournamentType.roundRobin:
          await _generateRoundRobinMatches(tournament);
          break;
        case TournamentType.swiss:
          // Not implemented yet
          throw UnimplementedError('Swiss tournaments are not implemented yet');
      }
    } catch (e) {
      logger.severe('Error generating matches: $e');
      rethrow;
    }
  }

  // Generate matches for a single elimination tournament
  Future<void> _generateSingleEliminationMatches(TournamentModel tournament) async {
    try {
      final participants = List<String>.from(tournament.participantIds);

      // Shuffle participants
      participants.shuffle();

      // Calculate number of rounds
      final numParticipants = participants.length;
      final numRounds = (numParticipants - 1).toRadixString(2).length;

      // Calculate number of byes
      final numMatches = 1 << numRounds;
      final numByes = numMatches - numParticipants;

      // Create first round matches
      final firstRoundMatches = <String>[];

      for (int i = 0; i < numMatches / 2; i++) {
        final redIndex = i;
        final blackIndex = numMatches - 1 - i;

        String redPlayerId;
        String blackPlayerId;

        if (redIndex < participants.length) {
          redPlayerId = participants[redIndex];
        } else {
          // Bye
          continue;
        }

        if (blackIndex < participants.length) {
          blackPlayerId = participants[blackIndex];
        } else {
          // Bye
          continue;
        }

        // Create match
        final matchId = await MatchRepository.instance.createMatch(
          tournamentId: tournament.id,
          redPlayerId: redPlayerId,
          blackPlayerId: blackPlayerId,
          scheduledTime: DateTime.now(),
          round: 1,
          matchNumber: i + 1,
        );

        firstRoundMatches.add(matchId);
      }

      // Add matches to tournament bracket
      await TournamentRepository.instance.update(tournament.id, {
        'brackets': {
          '1': firstRoundMatches,
        },
      });
    } catch (e) {
      logger.severe('Error generating single elimination matches: $e');
      rethrow;
    }
  }

  // Generate matches for a round robin tournament
  Future<void> _generateRoundRobinMatches(TournamentModel tournament) async {
    try {
      final participants = List<String>.from(tournament.participantIds);

      // If odd number of participants, add a dummy participant
      if (participants.length % 2 == 1) {
        participants.add('bye');
      }

      final numParticipants = participants.length;
      final numRounds = numParticipants - 1;
      final halfSize = numParticipants ~/ 2;

      // Create rounds
      final brackets = <String, List<String>>{};

      for (int round = 0; round < numRounds; round++) {
        final roundMatches = <String>[];

        for (int match = 0; match < halfSize; match++) {
          final redIndex = (round + match) % (numParticipants - 1);
          var blackIndex = (round - match + numParticipants - 1) % (numParticipants - 1);

          if (match == 0) {
            blackIndex = numParticipants - 1;
          }

          final redPlayerId = participants[redIndex];
          final blackPlayerId = participants[blackIndex];

          // Skip matches with bye
          if (redPlayerId == 'bye' || blackPlayerId == 'bye') {
            continue;
          }

          // Create match
          final matchId = await MatchRepository.instance.createMatch(
            tournamentId: tournament.id,
            redPlayerId: redPlayerId,
            blackPlayerId: blackPlayerId,
            scheduledTime: DateTime.now(),
            round: round + 1,
            matchNumber: match + 1,
          );

          roundMatches.add(matchId);
        }

        brackets['${round + 1}'] = roundMatches;
      }

      // Add matches to tournament bracket
      await TournamentRepository.instance.update(tournament.id, {
        'brackets': brackets,
      });
    } catch (e) {
      logger.severe('Error generating round robin matches: $e');
      rethrow;
    }
  }

  // Start a match
  Future<void> startMatch(String matchId) async {
    try {
      // Get the match
      final match = await MatchRepository.instance.get(matchId);

      if (match == null) {
        throw Exception('Match not found');
      }

      // Create a game for the match
      final gameId = await GameService.instance.startGame(
        redPlayerId: match.redPlayerId,
        blackPlayerId: match.blackPlayerId,
        isRanked: true,
        tournamentId: int.tryParse(match.tournamentId ?? ''),
        metadata: {
          'matchId': matchId,
          'round': match.round,
          'matchNumber': match.matchNumber,
        },
      );

      // Update match status
      await MatchRepository.instance.startMatch(matchId, gameId);

      logger.info('Match started: $matchId -> $gameId');
    } catch (e) {
      logger.severe('Error starting match: $e');
      rethrow;
    }
  }

  // End a match
  Future<void> endMatch(String matchId, String? winnerId, bool isDraw) async {
    try {
      // Get the match
      final match = await MatchRepository.instance.get(matchId);

      if (match == null) {
        throw Exception('Match not found');
      }

      // Update match status
      await MatchRepository.instance.endMatch(matchId, winnerId: winnerId, isDraw: isDraw);

      // If this is a tournament match, update the tournament bracket
      if (match.tournamentId != null) {
        await _advanceWinner(match.tournamentId!, match.round, match.matchNumber, winnerId);
      }

      logger.info('Match ended: $matchId');
    } catch (e) {
      logger.severe('Error ending match: $e');
      rethrow;
    }
  }

  // Advance winner to next round
  Future<void> _advanceWinner(String tournamentId, int round, int matchNumber, String? winnerId) async {
    try {
      // Get the tournament
      final tournament = await TournamentRepository.instance.get(tournamentId);

      if (tournament == null) {
        throw Exception('Tournament not found');
      }

      // Check if this is the final round
      if (round >= tournament.brackets.length) {
        // Tournament is complete
        await TournamentRepository.instance.updateStatus(tournamentId, TournamentStatus.completed);
        return;
      }

      // Calculate next round and match number
      final nextRound = round + 1;
      final nextMatchNumber = (matchNumber + 1) ~/ 2;

      // Get next round matches
      final nextRoundMatches = tournament.brackets['$nextRound'] ?? [];

      // Find the match in the next round
      String? nextMatchId;
      for (final matchId in nextRoundMatches) {
        final match = await MatchRepository.instance.get(matchId);
        if (match != null && match.matchNumber == nextMatchNumber) {
          nextMatchId = matchId;
          break;
        }
      }

      if (nextMatchId == null) {
        // Create a new match for the next round
        final nextMatchId = await MatchRepository.instance.createMatch(
          tournamentId: tournamentId,
          redPlayerId: winnerId ?? '',
          blackPlayerId: '', // Will be filled later
          scheduledTime: DateTime.now(),
          round: nextRound,
          matchNumber: nextMatchNumber,
        );

        // Add match to tournament bracket
        await TournamentRepository.instance.addMatchToBracket(tournamentId, '$nextRound', nextMatchId);
      } else {
        // Update the existing match
        final match = await MatchRepository.instance.get(nextMatchId);

        if (match == null) {
          throw Exception('Next match not found');
        }

        // Determine if this winner should be red or black player
        if (matchNumber % 2 == 1) {
          // Odd match number, winner goes to red
          await MatchRepository.instance.update(nextMatchId, {
            'red_player_id': winnerId,
          });
        } else {
          // Even match number, winner goes to black
          await MatchRepository.instance.update(nextMatchId, {
            'black_player_id': winnerId,
          });
        }
      }
    } catch (e) {
      logger.severe('Error advancing winner: $e');
      rethrow;
    }
  }

  // Get upcoming tournaments
  Future<List<TournamentModel>> getUpcomingTournaments({int limit = 10}) async {
    try {
      return await TournamentRepository.instance.getUpcomingTournaments(limit: limit);
    } catch (e) {
      logger.severe('Error getting upcoming tournaments: $e');
      rethrow;
    }
  }

  // Get active tournaments
  Future<List<TournamentModel>> getActiveTournaments({int limit = 10}) async {
    try {
      return await TournamentRepository.instance.getActiveTournaments(limit: limit);
    } catch (e) {
      logger.severe('Error getting active tournaments: $e');
      rethrow;
    }
  }

  // Get player's tournaments
  Future<List<TournamentModel>> getPlayerTournaments(String playerId, {int limit = 10}) async {
    try {
      return await TournamentRepository.instance.getTournamentsByParticipant(playerId, limit: limit);
    } catch (e) {
      logger.severe('Error getting player tournaments: $e');
      rethrow;
    }
  }

  // Get tournament matches
  Future<List<MatchModel>> getTournamentMatches(String tournamentId) async {
    try {
      return await MatchRepository.instance.getMatchesByTournament(tournamentId);
    } catch (e) {
      logger.severe('Error getting tournament matches: $e');
      rethrow;
    }
  }

  // Listen to tournament
  Stream<TournamentModel?> listenToTournament(String tournamentId) {
    return TournamentRepository.instance.listenToTournament(tournamentId);
  }

  // Listen to match
  Stream<MatchModel?> listenToMatch(String matchId) {
    return MatchRepository.instance.listenToMatch(matchId);
  }
}
