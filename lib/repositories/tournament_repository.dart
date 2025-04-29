import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';
import '../models/tournament_model.dart';
import 'base_repository.dart';

/// Repository for handling tournament data in Firestore
class TournamentRepository extends BaseRepository<TournamentModel> {
  // Singleton pattern
  static TournamentRepository? _instance;
  static TournamentRepository get instance => _instance ??= TournamentRepository._();

  TournamentRepository._() : super('tournaments');

  @override
  TournamentModel fromFirestore(DocumentSnapshot doc) {
    return TournamentModel.fromFirestore(doc);
  }

  @override
  Map<String, dynamic> toFirestore(TournamentModel model) {
    return model.toMap();
  }

  // Create a new tournament
  Future<String> createTournament({
    required String name,
    required String description,
    required String creatorId,
    required int maxParticipants,
    required Timestamp startTime,
    TournamentType type = TournamentType.singleElimination,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final tournamentModel = TournamentModel(
        id: '', // Will be set by Firestore
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
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tournamentDoc = await transaction.get(collection.doc(tournamentId));
        
        if (!tournamentDoc.exists) return;
        
        final tournamentData = tournamentDoc.data() as Map<String, dynamic>;
        final List<String> participantIds = List<String>.from(tournamentData['participantIds'] ?? []);
        final int maxParticipants = tournamentData['maxParticipants'] ?? 8;
        
        // Check if tournament is full
        if (participantIds.length >= maxParticipants) {
          throw Exception('Tournament is full');
        }
        
        // Check if user is already a participant
        if (!participantIds.contains(userId)) {
          participantIds.add(userId);
          transaction.update(collection.doc(tournamentId), {'participantIds': participantIds});
        }
      });
      
      logger.info('Participant added to tournament: $tournamentId -> $userId');
    } catch (e) {
      logger.severe('Error adding participant to tournament: $e');
      rethrow;
    }
  }

  // Remove a participant from a tournament
  Future<void> removeParticipant(String tournamentId, String userId) async {
    try {
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tournamentDoc = await transaction.get(collection.doc(tournamentId));
        
        if (!tournamentDoc.exists) return;
        
        final tournamentData = tournamentDoc.data() as Map<String, dynamic>;
        final List<String> participantIds = List<String>.from(tournamentData['participantIds'] ?? []);
        
        if (participantIds.contains(userId)) {
          participantIds.remove(userId);
          transaction.update(collection.doc(tournamentId), {'participantIds': participantIds});
        }
      });
      
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
        await update(tournamentId, {'endTime': Timestamp.now()});
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
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final tournamentDoc = await transaction.get(collection.doc(tournamentId));
        
        if (!tournamentDoc.exists) return;
        
        final tournamentData = tournamentDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> brackets = tournamentData['brackets'] ?? {};
        
        if (!brackets.containsKey(round)) {
          brackets[round] = [];
        }
        
        List<String> roundMatches = List<String>.from(brackets[round]);
        roundMatches.add(matchId);
        brackets[round] = roundMatches;
        
        transaction.update(collection.doc(tournamentId), {'brackets': brackets});
      });
      
      logger.info('Match added to tournament bracket: $tournamentId -> $round -> $matchId');
    } catch (e) {
      logger.severe('Error adding match to tournament bracket: $e');
      rethrow;
    }
  }

  // Get upcoming tournaments
  Future<List<TournamentModel>> getUpcomingTournaments({int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .where('status', isEqualTo: TournamentStatus.upcoming.index)
          .where('startTime', isGreaterThan: Timestamp.now())
          .orderBy('startTime')
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting upcoming tournaments: $e');
      rethrow;
    }
  }

  // Get active tournaments
  Future<List<TournamentModel>> getActiveTournaments({int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .where('status', isEqualTo: TournamentStatus.inProgress.index)
          .orderBy('startTime')
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting active tournaments: $e');
      rethrow;
    }
  }

  // Get tournaments by participant
  Future<List<TournamentModel>> getTournamentsByParticipant(String userId, {int limit = 10}) async {
    try {
      return await query((collection) => 
        collection
          .where('participantIds', arrayContains: userId)
          .orderBy('startTime', descending: true)
          .limit(limit)
      );
    } catch (e) {
      logger.severe('Error getting tournaments by participant: $e');
      rethrow;
    }
  }

  // Listen to tournament
  Stream<TournamentModel?> listenToTournament(String tournamentId) {
    return listen(tournamentId);
  }
}
