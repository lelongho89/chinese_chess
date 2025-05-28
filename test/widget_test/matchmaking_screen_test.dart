import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:xiangqi_mobile_app/src/models/matchmaking_queue_model.dart';
import 'package:xiangqi_mobile_app/src/models/user_model.dart';
import 'package:xiangqi_mobile_app/src/models/supabase_auth_service.dart';
import 'package:xiangqi_mobile_app/src/screens/matchmaking_screen.dart';
import 'package:xiangqi_mobile_app/src/services/matchmaking_service.dart';
import 'package:xiangqi_mobile_app/src/repositories/user_repository.dart';
import 'package:xiangqi_mobile_app/src/config/app_config.dart'; // For AppConfig.instance.matchTimeControlFormatted
import 'package:xiangqi_mobile_app/src/l10n/generated/app_localizations.dart'; // For l10n

// Generate mocks for the dependencies
@GenerateMocks([
  MatchmakingService,
  SupabaseAuthService,
  UserRepository,
])
import 'matchmaking_screen_test.mocks.dart';

// Helper to create a UserModel
UserModel createTestUserModel({
  String uid = 'test_user_id',
  String displayName = 'Test User',
  int eloRating = 1200,
  String email = 'test@example.com',
}) {
  return UserModel(
    uid: uid,
    email: email,
    displayName: displayName,
    eloRating: eloRating,
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
  );
}

// Helper to create a MatchmakingQueueModel
MatchmakingQueueModel createTestQueueModel({
  String id = 'test_queue_id',
  String userId = 'test_user_id',
  MatchmakingStatus status = MatchmakingStatus.waiting,
  int waitTimeSeconds = 0,
  DateTime? confirmationExpiresAt,
  Map<String, dynamic>? metadata,
}) {
  return MatchmakingQueueModel(
    id: id,
    userId: userId,
    eloRating: 1200,
    timeControl: 300, // Default, matches AppConfig
    status: status,
    joinedAt: DateTime.now().subtract(Duration(seconds: waitTimeSeconds)),
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    confirmationExpiresAt: confirmationExpiresAt,
    metadata: metadata ?? {},
  );
}

void main() {
  late MockMatchmakingService mockMatchmakingService;
  late MockSupabaseAuthService mockAuthService;
  late MockUserRepository mockUserRepository;

  final testUser = createTestUserModel();

  // Helper function to pump MatchmakingScreen with necessary providers
  Future<void> pumpMatchmakingScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<SupabaseAuthService>(create: (_) => mockAuthService),
          Provider<MatchmakingService>(create: (_) => mockMatchmakingService),
          // UserRepository is often accessed via ItsSingleton.instance,
          // so ensure that instance is replaced or provide it if screen expects it via Provider.
          // For this test, we assume it might be accessed via Provider or its instance is mocked globally.
          // If MatchmakingScreen itself doesn't directly use UserRepository via Provider, this might not be needed here.
          // However, _loadCurrentUser does use UserRepository.instance.
          // We will mock the instance directly in tests if needed, or ensure it's injectable.
        ],
        child: MaterialApp(
          // Provide AppLocalizations
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MatchmakingScreen(),
          // Mock a route for navigation test later
          routes: {
            '/game_screen': (context) => const Scaffold(body: Text('Mock Game Screen')),
          },
        ),
      ),
    );

    // Wait for initial loading (e.g., _loadCurrentUser, _checkExistingQueue)
    await tester.pumpAndSettle();
  }

  setUp(() {
    mockMatchmakingService = MockMatchmakingService();
    mockAuthService = MockSupabaseAuthService();
    mockUserRepository = MockUserRepository();

    // Mock user authentication
    when(mockAuthService.isAuthenticated).thenReturn(true);
    when(mockAuthService.user).thenReturn(User(
      id: testUser.uid,
      appMetadata: const {},
      userMetadata: {'display_name': testUser.displayName},
      aud: 'authenticated',
      createdAt: DateTime.now().toIso8601String(),
    ));

    // Mock UserRepository.instance.get(testUser.uid) used in _loadCurrentUser
    // This is tricky. If UserRepository is a true singleton and not injectable into the screen,
    // we need to ensure its instance returns the mock or the mock's behavior.
    // For now, we'll assume this mocking is handled if direct calls are made.
    // A common pattern is to have a static setter for the instance in testing.
    // If using a testing-specific service locator, it would be configured there.
    // For this test, we'll mock the specific calls made by the screen.
    UserRepository.instance = mockUserRepository; // Replace singleton instance
    when(mockUserRepository.get(testUser.uid)).thenAnswer((_) async => testUser);
    when(mockUserRepository.add(any)).thenAnswer((_) async => {}); // For new user creation branch

    // Mock initial queue checks
    when(mockMatchmakingService.getUserActiveQueue(testUser.uid)).thenAnswer((_) async => null);
    when(mockMatchmakingService.getQueueStats()).thenAnswer((_) async => {
      'total_waiting': 0,
      'average_wait_time_seconds': 0,
    });
  });

  tearDown(() {
    // Reset the UserRepository singleton after each test if it was modified
    // UserRepository.instance = UserRepository(); // Or original instance
  });


  testWidgets('Initial UI is displayed correctly', (WidgetTester tester) async {
    await pumpMatchmakingScreen(tester);

    // Verify "Play Now" button (using l10n context if available, or direct string)
    // Assuming AppLocalizations is available from MaterialApp wrapper
    final BuildContext context = tester.element(find.byType(MatchmakingScreen));
    final l10n = AppLocalizations.of(context)!;
    expect(find.text(l10n.findMatch), findsOneWidget);
    
    // Verify fixed match settings display
    expect(find.text('Match Settings'), findsOneWidget);
    expect(find.text(AppConfig.instance.matchTimeControlFormatted), findsOneWidget);
    expect(find.text('RANKED'), findsOneWidget); // From the badge
    expect(find.text('Side assignment (Red/Black) is automatically balanced for fair play'), findsOneWidget);

    // Verify no selectors for queue type/time control (these were removed previously)
    // This can be implicit if the "Play Now" section is simple.
  });

  testWidgets('Searching state UI is displayed and cancel works', (WidgetTester tester) async {
    // Mock joinQueue to succeed
    when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'new_queue_id');
    
    // StreamController for getUserActiveQueue updates
    final queueController = StreamController<MatchmakingQueueModel?>();
    when(mockMatchmakingService.getUserActiveQueue(testUser.uid))
        .thenAnswer((_) => queueController.stream.first); // Use .first if it's a one-time future from a stream

    await pumpMatchmakingScreen(tester);
    final BuildContext context = tester.element(find.byType(MatchmakingScreen));
    final l10n = AppLocalizations.of(context)!;

    // Tap "Play Now"
    await tester.tap(find.text(l10n.findMatch));
    await tester.pump(); // Start the action

    // Emit "waiting" state
    final waitingQueue = createTestQueueModel(status: MatchmakingStatus.waiting, waitTimeSeconds: 5);
    queueController.add(waitingQueue);
    await tester.pumpAndSettle(); // Let UI update

    // Verify "Searching" UI
    expect(find.text('Searching for a match...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Elapsed time: 0:05'), findsOneWidget); // Based on waitTimeSeconds
    expect(find.text(l10n.cancelSearch), findsOneWidget);

    // Tap "Cancel"
    when(mockMatchmakingService.leaveQueue(waitingQueue.id)).thenAnswer((_) async {});
    // After leaving, getUserActiveQueue should return null
    // Re-stubbing or ensuring the stream emits null after leaveQueue
    when(mockMatchmakingService.getUserActiveQueue(testUser.uid)).thenAnswer((_) async => null);


    await tester.tap(find.text(l10n.cancelSearch));
    await tester.pumpAndSettle();

    verify(mockMatchmakingService.leaveQueue(waitingQueue.id)).called(1);
    
    // Verify UI returns to initial state
    expect(find.text(l10n.findMatch), findsOneWidget); // "Play Now" button is back

    await queueController.close();
  });

  group('Pending Confirmation State', () {
    late StreamController<MatchmakingQueueModel?> queueController;
    final opponentUser = createTestUserModel(uid: 'opponent1', displayName: 'Opponent One', eloRating: 1234);
    final confirmationExpires = DateTime.now().add(const Duration(seconds: 10));

    setUp(() {
      queueController = StreamController<MatchmakingQueueModel?>.broadcast();
      // Mock joinQueue to succeed and lead to a pending confirmation state eventually
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'new_queue_id_pending');
      // Initial state for getUserActiveQueue after join
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid))
          .thenAnswer((_) => queueController.stream.first);
    });

    tearDown(() {
      queueController.close();
    });

    testWidgets('UI is displayed correctly and countdown works', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      // Tap "Play Now"
      await tester.tap(find.text(l10n.findMatch));
      await tester.pump(); 

      // 1. Transition to waiting
      final waitingQueue = createTestQueueModel(
        id: 'new_queue_id_pending',
        userId: testUser.uid,
        status: MatchmakingStatus.waiting,
      );
      queueController.add(waitingQueue);
      await tester.pumpAndSettle();
      expect(find.text('Searching for a match...'), findsOneWidget);

      // 2. Transition to pendingConfirmation
      final pendingQueue = createTestQueueModel(
        id: 'new_queue_id_pending',
        userId: testUser.uid,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: opponentUser.uid,
        confirmationExpiresAt: confirmationExpires,
        metadata: {
          'ai_opponent_id': null, // Explicitly not an AI match for this test case
          'opponent_display_name': opponentUser.displayName, // MatchmakingService would put this here
          'opponent_elo_rating': opponentUser.eloRating,     // MatchmakingService would put this here
          'side_assignment': {'red_player_id': testUser.uid, 'black_player_id': opponentUser.uid},
        }
      );
      // Mock user repo for _loadOpponentDetails if it were to fetch human opponent (but now assumed from metadata)
      // when(mockUserRepository.get(opponentUser.uid)).thenAnswer((_) async => opponentUser);
      
      queueController.add(pendingQueue);
      await tester.pumpAndSettle(); // Let UI update for pending state

      // Verify "Pending Confirmation" UI
      expect(find.text('Match Found!'), findsOneWidget);
      expect(find.text('Playing as Red'), findsOneWidget); // Based on side_assignment
      expect(find.text('vs ${opponentUser.displayName} (Elo: ${opponentUser.eloRating})'), findsOneWidget);
      expect(find.text(l10n.confirmReady.toUpperCase()), findsOneWidget);
      expect(find.text(l10n.cancelSearch), findsOneWidget); // Cancel button

      // Verify countdown (initial value)
      expect(find.text('Confirm within: 10 seconds'), findsOneWidget);

      // Advance timer by 3 seconds
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Confirm within: 7 seconds'), findsOneWidget);

      // Advance timer by another 5 seconds
      await tester.pump(const Duration(seconds: 5));
      expect(find.text('Confirm within: 2 seconds'), findsOneWidget);
       // Advance timer to expiration
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('Confirm within: 0 seconds'), findsOneWidget);
    });

    testWidgets('tapping READY calls confirmReady service method', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.findMatch));
      await tester.pump();

      final pendingQueue = createTestQueueModel(
        id: 'new_queue_id_pending_ready',
        userId: testUser.uid,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: opponentUser.uid,
        confirmationExpiresAt: DateTime.now().add(const Duration(seconds: 10)),
        metadata: { 'side_assignment': {'red_player_id': testUser.uid, 'black_player_id': opponentUser.uid},
                     'opponent_display_name': opponentUser.displayName, 'opponent_elo_rating': opponentUser.eloRating }
      );
      queueController.add(pendingQueue);
      await tester.pumpAndSettle();

      when(mockMatchmakingService.confirmReady(testUser.uid, pendingQueue.id)).thenAnswer((_) async {});

      await tester.tap(find.text(l10n.confirmReady.toUpperCase()));
      await tester.pumpAndSettle();

      verify(mockMatchmakingService.confirmReady(testUser.uid, pendingQueue.id)).called(1);
    });

    testWidgets('tapping Cancel calls leaveQueue service method', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.findMatch));
      await tester.pump();

      final pendingQueue = createTestQueueModel(
        id: 'new_queue_id_pending_cancel',
        userId: testUser.uid,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: opponentUser.uid,
        confirmationExpiresAt: DateTime.now().add(const Duration(seconds: 10)),
         metadata: { 'side_assignment': {'red_player_id': testUser.uid, 'black_player_id': opponentUser.uid},
                     'opponent_display_name': opponentUser.displayName, 'opponent_elo_rating': opponentUser.eloRating }
      );
      queueController.add(pendingQueue);
      await tester.pumpAndSettle();

      when(mockMatchmakingService.leaveQueue(pendingQueue.id)).thenAnswer((_) async {});
      // After leaving, getUserActiveQueue should return null
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid)).thenAnswer((_) async => null);


      await tester.tap(find.text(l10n.cancelSearch)); // Cancel button
      await tester.pumpAndSettle();

      verify(mockMatchmakingService.leaveQueue(pendingQueue.id)).called(1);
      expect(find.text(l10n.findMatch), findsOneWidget); // Back to initial UI
    });
  });

  // Tests for Cancelled/Expired, No Match Found, AI Disguise, and Navigation will follow.

  group('Match Cancelled/Expired/Failed Confirmation State', () {
    late StreamController<MatchmakingQueueModel?> queueController;
    final opponentUser = createTestUserModel(uid: 'opponentCancelled', displayName: 'Opponent Cancel', eloRating: 1300);

    setUp(() {
      queueController = StreamController<MatchmakingQueueModel?>.broadcast();
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'queue_cancel_test');
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid))
          .thenAnswer((_) => queueController.stream.first);
    });

    tearDown(() {
      queueController.close();
    });

    testWidgets('UI for cancelled match (from pendingConfirmation) is correct, retry and cancel work', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      // 1. Join queue
      await tester.tap(find.text(l10n.findMatch));
      await tester.pump();

      // 2. Transition to pendingConfirmation
      final pendingQueue = createTestQueueModel(
        id: 'queue_cancel_test',
        userId: testUser.uid,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: opponentUser.uid,
        confirmationExpiresAt: DateTime.now().add(const Duration(seconds: 10)),
         metadata: { 'side_assignment': {'red_player_id': testUser.uid, 'black_player_id': opponentUser.uid},
                     'opponent_display_name': opponentUser.displayName, 'opponent_elo_rating': opponentUser.eloRating }
      );
      queueController.add(pendingQueue);
      await tester.pumpAndSettle();
      expect(find.text('Match Found!'), findsOneWidget);

      // 3. Transition to cancelled
      final cancelledQueue = pendingQueue.copyWith(status: MatchmakingStatus.cancelled);
      // Reset confirmation related fields as MatchmakingService would
      final finalCancelledQueue = cancelledQueue.copyWith(
          matchedWithUserId: null, 
          matchId: null, 
          confirmationExpiresAt: null, 
          player1Confirmed: false, 
          player2Confirmed: false
      );

      queueController.add(finalCancelledQueue);
      await tester.pumpAndSettle();
      
      // Verify UI
      expect(find.text('Match canceled by you or opponent.'), findsOneWidget);
      expect(find.text('Please try again.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, l10n.retry), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.cancel), findsOneWidget);

      // Test Retry
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'queue_retry_id');
      // After retry, service will eventually return a new 'waiting' queue
      final waitingQueueAfterRetry = createTestQueueModel(id: 'queue_retry_id', status: MatchmakingStatus.waiting);
      // Ensure getUserActiveQueue is ready for the next emission for retry
      // We need to re-stub it or ensure the stream can be listened to again.
      // For simplicity, let's assume a new stream or a re-listenable stream.
      // This part can be tricky with stream.first. Let's make it a broadcast stream and emit again.
      // Or, re-mock the call:
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid)).thenAnswer((_) async => waitingQueueAfterRetry);


      await tester.tap(find.widgetWithText(ElevatedButton, l10n.retry));
      await tester.pumpAndSettle(); // Join queue and then update to waiting

      verify(mockMatchmakingService.joinQueue(userId: testUser.uid)).called(2); // Called once initially, once for retry
      expect(find.text('Searching for a match...'), findsOneWidget); // Back to searching UI

      // Test Cancel (from cancelled state)
      // First, get back to cancelled state
      queueController.add(finalCancelledQueue); // Emit cancelled state again
      await tester.pumpAndSettle();
      expect(find.text('Match canceled by you or opponent.'), findsOneWidget);

      await tester.tap(find.widgetWithText(TextButton, l10n.cancel));
      await tester.pumpAndSettle();
      expect(find.text(l10n.findMatch), findsOneWidget); // Back to initial UI
    });
  });
  
  group('No Match Found State (Timeout from waiting)', () {
    late StreamController<MatchmakingQueueModel?> queueController;
     setUp(() {
      queueController = StreamController<MatchmakingQueueModel?>.broadcast();
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'queue_timeout_test');
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid))
          .thenAnswer((_) => queueController.stream.first);
    });

    tearDown(() {
      queueController.close();
    });

    testWidgets('UI for no match found (queue becomes null) is correct, retry and cancel work', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      // 1. Join queue
      await tester.tap(find.text(l10n.findMatch));
      await tester.pump();

      // 2. Transition to waiting
      final waitingQueue = createTestQueueModel(id: 'queue_timeout_test', status: MatchmakingStatus.waiting);
      queueController.add(waitingQueue);
      await tester.pumpAndSettle();
      expect(find.text('Searching for a match...'), findsOneWidget);

      // 3. Simulate timeout by making queue null
      queueController.add(null);
      await tester.pumpAndSettle();

      // Verify UI
      expect(find.text('No match found this time.'), findsOneWidget);
      expect(find.text('The queue was empty or no suitable opponent was available.'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, l10n.retry), findsOneWidget);
      expect(find.widgetWithText(TextButton, l10n.cancel), findsOneWidget);
      
      // Test Retry
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'queue_retry_after_null_id');
      final waitingQueueAfterRetry = createTestQueueModel(id: 'queue_retry_after_null_id', status: MatchmakingStatus.waiting);
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid)).thenAnswer((_) async => waitingQueueAfterRetry);

      await tester.tap(find.widgetWithText(ElevatedButton, l10n.retry));
      await tester.pumpAndSettle();
      
      verify(mockMatchmakingService.joinQueue(userId: testUser.uid)).called(2);
      expect(find.text('Searching for a match...'), findsOneWidget);
    });
  });

  group('Navigation to Game Screen', () {
     late StreamController<MatchmakingQueueModel?> queueController;
     final opponentUser = createTestUserModel(uid: 'opponentNav', displayName: 'Nav Opponent', eloRating: 1400);


    setUp(() {
      queueController = StreamController<MatchmakingQueueModel?>.broadcast();
      when(mockMatchmakingService.joinQueue(userId: testUser.uid)).thenAnswer((_) async => 'qNavId');
      when(mockMatchmakingService.getUserActiveQueue(testUser.uid))
          .thenAnswer((_) => queueController.stream.first);
    });

    tearDown(() {
      queueController.close();
    });

    testWidgets('Placeholder dialog is shown when match status becomes "matched"', (WidgetTester tester) async {
      await pumpMatchmakingScreen(tester);
      final BuildContext context = tester.element(find.byType(MatchmakingScreen));
      final l10n = AppLocalizations.of(context)!;

      await tester.tap(find.text(l10n.findMatch));
      await tester.pump();

      // Go through pending confirmation first
       final pendingQueue = createTestQueueModel(
        id: 'qNavId',
        userId: testUser.uid,
        status: MatchmakingStatus.pendingConfirmation,
        matchedWithUserId: opponentUser.uid,
        confirmationExpiresAt: DateTime.now().add(const Duration(seconds: 10)),
        metadata: { 
          'side_assignment': {'red_player_id': testUser.uid, 'black_player_id': opponentUser.uid},
          'opponent_display_name': opponentUser.displayName, 
          'opponent_elo_rating': opponentUser.eloRating 
        }
      );
      queueController.add(pendingQueue);
      await tester.pumpAndSettle();
      expect(find.text('Match Found!'), findsOneWidget);

      // Now transition to matched
      final matchedQueue = pendingQueue.copyWith(status: MatchmakingStatus.matched, matchId: 'actual_game_id_123');
      queueController.add(matchedQueue);
      await tester.pumpAndSettle(); // Allow dialog to show

      // Verify dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Match Ready!'), findsOneWidget);
      expect(find.text('Navigating to game actual_game_id_123.\nOpponent: ${opponentUser.displayName} (Elo: ${opponentUser.eloRating})\nYour Color: Red'), findsOneWidget);
      
      // Close the dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      // Screen should be back to initial state (or navigated away if real navigation was in place)
      expect(find.text(l10n.findMatch), findsOneWidget);
    });
  });
}
