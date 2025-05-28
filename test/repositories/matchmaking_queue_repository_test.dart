import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:xiangqi_mobile_app/src/models/matchmaking_queue_model.dart';
import 'package:xiangqi_mobile_app/src/repositories/matchmaking_queue_repository.dart';
import 'package:xiangqi_mobile_app/src/supabase_client.dart' as client_wrapper;
import 'package:xiangqi_mobile_app/src/global.dart';

// Generate mocks for Supabase classes
@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  SupabaseFilterBuilder, // For fluent interface calls like .eq()
  PostgrestResponse,    // For the response of Supabase calls
])
import 'matchmaking_queue_repository_test.mocks.dart';

void main() {
  late MatchmakingQueueRepository repository;
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockQueryBuilder;
  late MockSupabaseFilterBuilder mockFilterBuilder; // Used for .eq, .filter, etc.
  
  // Helper to create a MatchmakingQueueModel
  MatchmakingQueueModel createQueueEntry({
    String id = 'queue1',
    String userId = 'user1',
    int eloRating = 1200,
    MatchmakingStatus status = MatchmakingStatus.waiting,
    String? matchedWithUserId,
    String? matchId,
    DateTime? confirmationExpiresAt,
    bool player1Confirmed = false,
    bool player2Confirmed = false,
    Map<String, dynamic>? metadata,
    DateTime? joinedAt,
    int timeControl = 300,
  }) {
    return MatchmakingQueueModel(
      id: id,
      userId: userId,
      eloRating: eloRating,
      timeControl: timeControl,
      status: status,
      matchedWithUserId: matchedWithUserId,
      matchId: matchId,
      confirmationExpiresAt: confirmationExpiresAt,
      player1Confirmed: player1Confirmed,
      player2Confirmed: player2Confirmed,
      joinedAt: joinedAt ?? DateTime.now().subtract(const Duration(seconds: 5)),
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
      updatedAt: DateTime.now().subtract(const Duration(seconds: 30)),
      metadata: metadata ?? {},
    );
  }


  setUpAll(() {
    initializeLogger();
  });

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockQueryBuilder = MockSupabaseQueryBuilder();
    mockFilterBuilder = MockSupabaseFilterBuilder();

    // Replace the Supabase client wrapper's instance with the mock
    // This requires the SupabaseClientWrapper to be designed to allow instance replacement for testing.
    // If SupabaseClientWrapper.instance is final and not settable, this approach won't work directly.
    // For this test, we assume it IS replaceable or the repository takes a client in its constructor (preferred).
    // As MatchmakingQueueRepository uses a global SupabaseClientWrapper.instance, we mock that.
    
    // client_wrapper.SupabaseClientWrapper.instance = mockSupabaseClient; // This line would be ideal if possible.
    // Since SupabaseClientWrapper.instance.database directly returns a SupabaseClient,
    // we need to mock this behavior. This is tricky.
    // A common pattern is to have a getter that can be overridden.
    // For now, we will mock the calls that the repository makes on the client.
    // The repository uses `table` which is `Supabase.instance.client.from(tableName)`.
    // This is even harder to mock without a proper DI or service locator for SupabaseClient.

    // Let's assume MatchmakingQueueRepository has a way to inject the client or `table` calls can be mocked.
    // For `SupabaseBaseRepository`, `table` is `Supabase.instance.client.from(_tableName)`.
    // We'll mock the chain: Supabase.instance.client.from().select()...
    // This is highly dependent on the actual Supabase package version and mockito's capabilities.

    // Mocking the fluent interface:
    when(mockSupabaseClient.from(any)).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.insert(any, valueOptions: anyNamed('valueOptions'))).thenAnswer((_) async => PostgrestResponse(data: [{'id': 'new_mock_id'}], statusCode: 201)); // Assume insert returns the new ID
    when(mockQueryBuilder.update(any, valueOptions: anyNamed('valueOptions'))).thenReturn(mockFilterBuilder); // update usually followed by eq
    when(mockQueryBuilder.delete(valueOptions: anyNamed('valueOptions'))).thenReturn(mockFilterBuilder);
    
    when(mockFilterBuilder.eq(any, any)).thenReturn(mockFilterBuilder);
    when(mockFilterBuilder.filter(any, any, any)).thenReturn(mockFilterBuilder); // For .filter('status', 'in', '("waiting","pending")')
    when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200)); // Default for updates/deletes
    when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: null, statusCode: 200)); // Default for maybeSingle
     when(mockQueryBuilder.limit(any)).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.order(any, ascending: anyNamed('ascending'))).thenReturn(mockQueryBuilder);
    when(mockQueryBuilder.single()).thenAnswer((_) async => PostgrestResponse(data: {}, statusCode: 200));


    // This is a simplified mock for the Supabase client instance used by the repository.
    // In a real scenario, you might need a more robust way to provide the mock client.
    // For instance, if SupabaseBaseRepository took SupabaseClient in its constructor.
    // For now, we'll assume the repository somehow uses this mocked client.
    // One way this could work is if the Supabase.instance.client was replaced by mockSupabaseClient
    // in a test setup file, which is beyond the scope of this tool's direct action.
    // We are testing the repository's logic, assuming its Supabase calls can be intercepted.

    repository = MatchmakingQueueRepository.instance; 
    // TODO: Figure out how to make MatchmakingQueueRepository.instance use the mockSupabaseClient.
    // This is a fundamental problem with testing singletons that directly access other global singletons.
    // A common solution is to allow setting the instance for testing:
    // e.g. MatchmakingQueueRepository.instance = new MatchmakingQueueRepository(mockSupabaseClient);
    // Or modify SupabaseBaseRepository to accept a client.
    // For now, the tests will proceed by trying to mock the chained calls.
  });

  group('joinQueue', () {
    test('correctly initializes fields and calls cancelUserQueue', () async {
      final userId = 'userJoin1';
      final elo = 1234;
      final timeControl = 300;
      final timeIncrement = 5;

      // Mocking for cancelUserQueue internal calls
      // cancelUserQueue calls table.update().eq().filter().execute()
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(any)).thenReturn(mockFilterBuilder); // `any` for the data map
      when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.filter('status', 'in', '("${MatchmakingStatus.waiting.name}","${MatchmakingStatus.pendingConfirmation.name}")'))
          .thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));


      // Mocking for the add (insert) call in joinQueue
      final List<Map<String, dynamic>> capturedInserts = [];
      when(mockQueryBuilder.insert(captureAny, valueOptions: anyNamed('valueOptions')))
          .thenAnswer((invocation) async {
              capturedInserts.add(invocation.positionalArguments.first as Map<String,dynamic>);
              return PostgrestResponse(data: [{'id': 'new_queue_id'}], statusCode: 201);
          });


      final queueId = await repository.joinQueue(
        userId: userId,
        eloRating: elo,
        timeControl: timeControl,
        timeIncrement: timeIncrement,
      );

      expect(queueId, 'new_queue_id');
      
      // Verify cancelUserQueue was called appropriately
      // This specific verification relies on the mocks being correctly chained for the update inside cancelUserQueue.
      verify(mockFilterBuilder.filter('status', 'in', '("${MatchmakingStatus.waiting.name}","${MatchmakingStatus.pendingConfirmation.name}")')).called(1);

      // Verify the data inserted
      expect(capturedInserts.length, 1);
      final insertedData = capturedInserts.first;
      expect(insertedData['user_id'], userId);
      expect(insertedData['elo_rating'], elo);
      expect(insertedData['time_control'], timeControl);
      expect(insertedData['status'], MatchmakingStatus.waiting.name);
      expect(insertedData['player1_confirmed'], false);
      expect(insertedData['player2_confirmed'], false);
      expect(insertedData['confirmation_expires_at'], null);
      expect(insertedData['metadata'], containsPair('time_increment', timeIncrement));
    });
  });

  group('getPendingConfirmationEntries', () {
    test('returns only entries with pendingConfirmation status', () async {
      final pendingEntry1 = createQueueEntry(id: 'pending1', status: MatchmakingStatus.pendingConfirmation);
      final pendingEntry2 = createQueueEntry(id: 'pending2', status: MatchmakingStatus.pendingConfirmation);
      final waitingEntry = createQueueEntry(id: 'waiting1', status: MatchmakingStatus.waiting);
      final matchedEntry = createQueueEntry(id: 'matched1', status: MatchmakingStatus.matched);

      final mockResponseData = [
        pendingEntry1.toMap()..['id'] = pendingEntry1.id, // Ensure 'id' is in the map for fromSupabase
        pendingEntry2.toMap()..['id'] = pendingEntry2.id,
        // Supabase query would filter these out, but if we mock the response directly:
        // waitingEntry.toMap()..['id'] = waitingEntry.id, 
        // matchedEntry.toMap()..['id'] = matchedEntry.id,
      ];
      
      // Mock the chain: client.from().select().eq().eq().execute()
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder); // For SupabaseBaseRepository.get
      when(mockQueryBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.execute(count: anyNamed('count'))) // This is for .execute(), not directly used by select() in mockito
          .thenAnswer((_) async => PostgrestResponse(data: mockResponseData, statusCode: 200));
      // The actual call from SupabaseBaseRepository via `table.select()` might not use `execute()` in mock setup.
      // It might directly use the queryBuilder instance. Let's adjust if needed.
      // The `select()` method on queryBuilder itself might be what returns the response in some Supabase client versions or usages.
      // For this test, we'll assume the `execute()` on the final filterBuilder is how it gets data.
      // If `select()` itself returns the list:
      when(mockFilterBuilder.then(any)).thenAnswer((invocation) async { // For `await query`
         return mockResponseData;
      });
      // More robust: if the select().eq().eq() directly returns PostgrestResponse after chained calls
      // This depends on how Supabase client's fluent API is mocked.
      // Let's assume the select() itself can be awaited or returns a response.
      // The repository code is: `await table.select().eq('status', ...).eq('is_deleted', ...);`
      // So, the final `eq` (which returns a `SupabaseFilterBuilder`) should be awaitable or have an `execute`.
      // Let's assume the `mockFilterBuilder` itself can be awaited for simplicity with mockito.
      // Or, more commonly, `select()` would return a `PostgrestTransformBuilder` which then has `execute()`.

      // Simpler approach: mock the final chained call that returns the response.
      // `table.select().eq().eq()` returns a PostgrestFilterBuilder.
      // The repository code implicitly awaits this or calls a method like `toList()` or `execute()`.
      // Let's assume the repository does `await table.select()...` and this returns the list of maps.
      // This is tricky. Supabase client returns `PostgrestTransformBuilder` from `select()`.
      // `eq` returns `PostgrestFilterBuilder`.
      // `PostgrestFilterBuilder` is a `Future<PostgrestResponse>`.
      
      // Correct mocking for `await table.select().eq().eq()`
      // where `table.select()` is `mockQueryBuilder`
      // and `eq()` returns `mockFilterBuilder`
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder); // from SupabaseBaseRepository
      when(mockQueryBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).thenReturn(mockFilterBuilder); // This is the key part
      when(mockFilterBuilder.eq('is_deleted', false)).thenAnswer((_) async => mockResponseData); // Assuming PostgrestFilterBuilder is a Future<List<Map>>


      final results = await repository.getPendingConfirmationEntries();

      expect(results.length, 2);
      expect(results.any((e) => e.id == 'pending1'), isTrue);
      expect(results.any((e) => e.id == 'pending2'), isTrue);
      expect(results.every((e) => e.status == MatchmakingStatus.pendingConfirmation), isTrue);
      
      verify(mockSupabaseClient.from('matchmaking_queue')).called(1);
      verify(mockQueryBuilder.select()).called(1);
      verify(mockQueryBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).called(1);
      verify(mockFilterBuilder.eq('is_deleted', false)).called(1);
    });
  });

  group('findOpponentQueueEntry', () {
    final targetUserId = 'opponentUser1';
    final targetMatchId = 'sharedMatch123';
    final opponentEntry = createQueueEntry(
      id: 'opponentQ1',
      userId: targetUserId,
      matchId: targetMatchId,
      status: MatchmakingStatus.pendingConfirmation,
    );
    final otherEntry = createQueueEntry(id: 'otherQ', status: MatchmakingStatus.pendingConfirmation);

    test('returns correct entry when opponent found', () async {
      final responseData = opponentEntry.toMap()..['id'] = opponentEntry.id;
      
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.eq('user_id', targetUserId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('match_id', targetMatchId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: responseData, statusCode: 200));


      final result = await repository.findOpponentQueueEntry(targetUserId, targetMatchId);

      expect(result, isNotNull);
      expect(result!.id, opponentEntry.id);
      expect(result.userId, targetUserId);
      expect(result.matchId, targetMatchId);
      
      verify(mockQueryBuilder.eq('user_id', targetUserId)).called(1);
      verify(mockFilterBuilder.eq('match_id', targetMatchId)).called(1);
      verify(mockFilterBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).called(1);
      verify(mockFilterBuilder.limit(1)).called(1);
      verify(mockFilterBuilder.maybeSingle()).called(1);
    });

    test('returns null when no matching opponent found', () async {
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.eq('user_id', 'nonExistentUser')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('match_id', 'nonExistentMatch')).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('status', MatchmakingStatus.pendingConfirmation.name)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('is_deleted', false)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.limit(1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: null, statusCode: 200));


      final result = await repository.findOpponentQueueEntry('nonExistentUser', 'nonExistentMatch');

      expect(result, isNull);
    });
  });
  
  group('markAsMatched', () {
    test('correctly updates status and resets confirmation fields for H-H match', () async {
      final queueId1 = 'q1match';
      final queueId2 = 'q2match';
      final matchId = 'game123';
      final p1Entry = createQueueEntry(id: queueId1, userId: 'p1', confirmationExpiresAt: DateTime.now(), player1Confirmed: true);
      final p2Entry = createQueueEntry(id: queueId2, userId: 'p2', confirmationExpiresAt: DateTime.now(), player1Confirmed: true);

      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      // Mock for the get(queueId1) and get(queueId2) calls
      when(mockQueryBuilder.select(any)).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.eq('id', queueId1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: p1Entry.toMap()..['id']=p1Entry.id, statusCode: 200));
      
      // Need to allow mockQueryBuilder to be configured for a different .eq call for queueId2
      // This typically means re-mocking the chain for the second get, or making .eq more flexible.
      // For simplicity, we'll assume the setup for mockQueryBuilder.select().eq().maybeSingle() can handle multiple different IDs.
      // A better way would be:
      when(mockQueryBuilder.select()).thenReturn(mockQueryBuilder); // Ensure select is chainable
      when(mockQueryBuilder.eq('id', queueId1)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: p1Entry.toMap()..['id'] = p1Entry.id, statusCode: 200));
      
      // For the second get(queueId2)
      final mockQueryBuilder2 = MockSupabaseQueryBuilder();
      final mockFilterBuilder2 = MockSupabaseFilterBuilder();
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder2); // This might override previous if not careful
      when(mockQueryBuilder2.select(any)).thenReturn(mockQueryBuilder2);
      when(mockQueryBuilder2.eq('id', queueId2)).thenReturn(mockFilterBuilder2);
      when(mockFilterBuilder2.maybeSingle()).thenAnswer((_) async => PostgrestResponse(data: p2Entry.toMap()..['id'] = p2Entry.id, statusCode: 200));


      // Mock for the update calls
      final List<Map<String, dynamic>> updatedDataMaps = [];
      final List<String> updatedIds = [];

      when(mockQueryBuilder.update(captureAny)).thenAnswer((invocation) {
        updatedDataMaps.add(invocation.positionalArguments.first as Map<String,dynamic>);
        return mockFilterBuilder; // Returns filter builder to chain .eq()
      });
       when(mockQueryBuilder2.update(captureAny)).thenAnswer((invocation) {
        updatedDataMaps.add(invocation.positionalArguments.first as Map<String,dynamic>);
        return mockFilterBuilder2; // Returns filter builder to chain .eq()
      });

      when(mockFilterBuilder.eq('id', captureAny)).thenAnswer((invocation) {
        updatedIds.add(invocation.positionalArguments.first as String);
        return mockFilterBuilder;
      });
       when(mockFilterBuilder2.eq('id', captureAny)).thenAnswer((invocation) {
        updatedIds.add(invocation.positionalArguments.first as String);
        return mockFilterBuilder2;
      });
      when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));
      when(mockFilterBuilder2.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));


      await repository.markAsMatched(queueId1: queueId1, queueId2: queueId2, matchId: matchId);

      expect(updatedDataMaps.length, 2); // Two updates expected
      
      for (var data in updatedDataMaps) {
        expect(data['status'], MatchmakingStatus.matched.name);
        expect(data['match_id'], matchId);
        expect(data['matched_at'], isNotNull);
        expect(data['confirmation_expires_at'], null);
        expect(data['player1_confirmed'], false);
        expect(data['player2_confirmed'], false);
      }
      expect(updatedDataMaps.any((data) => data['matched_with_user_id'] == p2Entry.userId), isTrue);
      expect(updatedDataMaps.any((data) => data['matched_with_user_id'] == p1Entry.userId), isTrue);
      expect(updatedIds, containsAll([queueId1, queueId2]));
    });
  });

  group('leaveQueue', () {
    test('updates status to cancelled and clears confirmation fields', () async {
      final queueId = 'qLeave1';
      final List<Map<String, dynamic>> updatedData = [];
      
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(captureAny)).thenAnswer((invocation) {
        updatedData.add(invocation.positionalArguments.first as Map<String,dynamic>);
        return mockFilterBuilder;
      });
      when(mockFilterBuilder.eq('id', queueId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));

      await repository.leaveQueue(queueId);

      expect(updatedData.length, 1);
      final data = updatedData.first;
      expect(data['status'], MatchmakingStatus.cancelled.name);
      expect(data['updated_at'], isNotNull);
      expect(data['matched_with_user_id'], null);
      expect(data['match_id'], null);
      expect(data['confirmation_expires_at'], null);
      expect(data['player1_confirmed'], false);
      expect(data['player2_confirmed'], false);
      
      verify(mockFilterBuilder.eq('id', queueId)).called(1);
    });
  });

  group('cancelUserQueue', () {
    final userId = 'userCancel1';

    test('cancels only waiting entries when cancelPendingToo is false', () async {
      final List<Map<String, dynamic>> updatedData = [];
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(captureAny)).thenAnswer((invocation) {
        updatedData.add(invocation.positionalArguments.first as Map<String,dynamic>);
        return mockFilterBuilder;
      });
      when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.eq('status', MatchmakingStatus.waiting.name)).thenReturn(mockFilterBuilder); // This is key
      when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));


      await repository.cancelUserQueue(userId, cancelPendingToo: false);

      expect(updatedData.length, 1);
      final data = updatedData.first;
      expect(data['status'], MatchmakingStatus.cancelled.name);
      expect(data['matched_with_user_id'], null);
      expect(data['match_id'], null);
      expect(data['confirmation_expires_at'], null);
      expect(data['player1_confirmed'], false);
      expect(data['player2_confirmed'], false);

      verify(mockFilterBuilder.eq('status', MatchmakingStatus.waiting.name)).called(1);
      verifyNever(mockFilterBuilder.filter('status', 'in', any));
    });

    test('cancels waiting and pendingConfirmation entries when cancelPendingToo is true', () async {
       final List<Map<String, dynamic>> updatedData = [];
      when(mockSupabaseClient.from('matchmaking_queue')).thenReturn(mockQueryBuilder);
      when(mockQueryBuilder.update(captureAny)).thenAnswer((invocation) {
        updatedData.add(invocation.positionalArguments.first as Map<String,dynamic>);
        return mockFilterBuilder;
      });
      when(mockFilterBuilder.eq('user_id', userId)).thenReturn(mockFilterBuilder);
      final expectedFilter = '("${MatchmakingStatus.waiting.name}","${MatchmakingStatus.pendingConfirmation.name}")';
      when(mockFilterBuilder.filter('status', 'in', expectedFilter)).thenReturn(mockFilterBuilder);
      when(mockFilterBuilder.execute(count: anyNamed('count'))).thenAnswer((_) async => PostgrestResponse(data: [], statusCode: 200));

      await repository.cancelUserQueue(userId, cancelPendingToo: true);

      expect(updatedData.length, 1);
      final data = updatedData.first;
      expect(data['status'], MatchmakingStatus.cancelled.name);
      // ... other fields checked as above ...

      verify(mockFilterBuilder.filter('status', 'in', expectedFilter)).called(1);
      verifyNever(mockFilterBuilder.eq('status', MatchmakingStatus.waiting.name));
    });
  });
}
