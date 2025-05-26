import '../global.dart';
import '../models/tournament_model.dart';
import 'supabase_base_repository.dart';

/// Repository for handling tournament data in Supabase
class TournamentRepository extends SupabaseBaseRepository<TournamentModel> {
  // Singleton pattern
  static TournamentRepository? _instance;
  static TournamentRepository get instance => _instance ??= TournamentRepository._();

  TournamentRepository._() : super('tournaments');

  @override
  TournamentModel fromSupabase(Map<String, dynamic> data, String id) {
    return TournamentModel.fromSupabase(data, id);
  }

  @override
  Map<String, dynamic> toSupabase(TournamentModel model) {
    return model.toMap();
  }

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
      final tournamentModel = TournamentModel(
        id: '', // Will be set by Supabase
        name: name,
        description: description,
        creatorId: creatorId,
        maxParticipants: maxParticipants,
        startTime: startTime,
        type: type,
        settings: settings,
        metadata: metadata,
      );

      final tournamentId = await add(tournamentModel);
      logger.info('Tournament created: $tournamentId');
      return tournamentId;
    } catch (e) {
      logger.severe('Error creating tournament: $e');
      rethrow;
    }
  }

  // Add a participant to a tournament
  Future<void> addParticipant(String tournamentId, String userId) async {
    try {
      // Get current tournament data
      final tournament = await get(tournamentId);
      if (tournament == null) return;

      final List<String> participantIds = List<String>.from(tournament.participantIds);
      final int maxParticipants = tournament.maxParticipants;

      // Check if tournament is full
      if (participantIds.length >= maxParticipants) {
        throw Exception('Tournament is full');
      }

      // Check if user is already a participant
      if (!participantIds.contains(userId)) {
        participantIds.add(userId);
        await update(tournamentId, {'participant_ids': participantIds});
      }

      logger.info('Participant added to tournament: $tournamentId -> $userId');
    } catch (e) {
      logger.severe('Error adding participant to tournament: $e');
      rethrow;
    }
  }

  // Remove a participant from a tournament
  Future<void> removeParticipant(String tournamentId, String userId) async {
    try {
      // Get current tournament data
      final tournament = await get(tournamentId);
      if (tournament == null) return;

      final List<String> participantIds = List<String>.from(tournament.participantIds);

      if (participantIds.contains(userId)) {
        participantIds.remove(userId);
        await update(tournamentId, {'participant_ids': participantIds});
      }

      logger.info('Participant removed from tournament: $tournamentId -> $userId');
    } catch (e) {
      logger.severe('Error removing participant from tournament: $e');
      rethrow;
    }
  }

  // Update tournament status
  Future<void> updateStatus(String tournamentId, TournamentStatus status) async {
    try {
      await update(tournamentId, {'status': status.index});

      // If tournament is completed, set end time
      if (status == TournamentStatus.completed) {
        await update(tournamentId, {'end_time': DateTime.now().toIso8601String()});
      }

      logger.info('Tournament status updated: $tournamentId -> ${status.name}');
    } catch (e) {
      logger.severe('Error updating tournament status: $e');
      rethrow;
    }
  }

  // Add a match to a tournament bracket
  Future<void> addMatchToBracket(String tournamentId, String round, String matchId) async {
    try {
      // Get current tournament data
      final tournament = await get(tournamentId);
      if (tournament == null) return;

      // Create a mutable copy of the brackets
      Map<String, List<String>> brackets = Map<String, List<String>>.from(tournament.brackets);

      if (!brackets.containsKey(round)) {
        brackets[round] = [];
      }

      List<String> roundMatches = List<String>.from(brackets[round] ?? []);
      roundMatches.add(matchId);
      brackets[round] = roundMatches;

      await update(tournamentId, {'brackets': brackets});

      logger.info('Match added to tournament bracket: $tournamentId -> $round -> $matchId');
    } catch (e) {
      logger.severe('Error adding match to tournament bracket: $e');
      rethrow;
    }
  }

  // Get upcoming tournaments
  Future<List<TournamentModel>> getUpcomingTournaments({int limit = 10}) async {
    try {
      final now = DateTime.now().toIso8601String();

      final response = await table
          .select()
          .eq('status', TournamentStatus.upcoming.index)
          .gt('start_time', now)
          .order('start_time')
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting upcoming tournaments: $e');
      rethrow;
    }
  }

  // Get active tournaments
  Future<List<TournamentModel>> getActiveTournaments({int limit = 10}) async {
    try {
      final response = await table
          .select()
          .eq('status', TournamentStatus.inProgress.index)
          .order('start_time')
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting active tournaments: $e');
      rethrow;
    }
  }

  // Get tournaments by participant
  Future<List<TournamentModel>> getTournamentsByParticipant(String userId, {int limit = 10}) async {
    try {
      final response = await table
          .select()
          .contains('participant_ids', [userId])
          .order('start_time', ascending: false)
          .limit(limit);

      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting tournaments by participant: $e');
      rethrow;
    }
  }

  // Get tournament details (renamed from listenToTournament)
  Future<TournamentModel?> getTournamentDetails(String tournamentId) async {
    try {
      final response = await table
          .select()
          .eq('id', tournamentId)
          .maybeSingle();

      if (response != null) {
        final id = response['id'] as String;
        return fromSupabase(response, id);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting tournament details: $e');
      rethrow;
    }
  }
}
