import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:chinese_chess/models/user_model.dart';
import 'package:chinese_chess/repositories/user_repository.dart';
import 'package:chinese_chess/supabase_client.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([
  SupabaseClient,
  SupabaseQueryBuilder,
  PostgrestFilterBuilder,
  PostgrestResponse,
  User,
])
void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockSupabaseQueryBuilder mockSupabaseQueryBuilder;
  late MockPostgrestFilterBuilder mockPostgrestFilterBuilder;
  late MockPostgrestResponse mockPostgrestResponse;
  late UserRepository userRepository;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockSupabaseQueryBuilder = MockSupabaseQueryBuilder();
    mockPostgrestFilterBuilder = MockPostgrestFilterBuilder();
    mockPostgrestResponse = MockPostgrestResponse();

    // Mock Supabase client
    SupabaseClient.instance = mockSupabaseClient;

    // Mock table query builder
    when(mockSupabaseClient.from('users')).thenReturn(mockSupabaseQueryBuilder);

    // Mock select
    when(mockSupabaseQueryBuilder.select()).thenReturn(mockPostgrestFilterBuilder);

    // Mock filter operations
    when(mockPostgrestFilterBuilder.eq('id', any)).thenReturn(mockPostgrestFilterBuilder);
    when(mockPostgrestFilterBuilder.order(any, ascending: anyNamed('ascending')))
        .thenReturn(mockPostgrestFilterBuilder);
    when(mockPostgrestFilterBuilder.limit(any)).thenReturn(mockPostgrestFilterBuilder);

    // Mock response
    when(mockPostgrestFilterBuilder.execute()).thenAnswer((_) async => mockPostgrestResponse);
    when(mockPostgrestResponse.data).thenReturn([
      {
        'id': 'test_user_id',
        'email': 'test@example.com',
        'display_name': 'Test User',
        'elo_rating': 1200,
        'games_played': 10,
        'games_won': 5,
        'games_lost': 3,
        'games_draw': 2,
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
      }
    ]);

    // Mock insert, update, delete
    when(mockSupabaseQueryBuilder.insert(any)).thenReturn(mockPostgrestFilterBuilder);
    when(mockSupabaseQueryBuilder.update(any)).thenReturn(mockPostgrestFilterBuilder);
    when(mockSupabaseQueryBuilder.delete()).thenReturn(mockPostgrestFilterBuilder);

    // Create UserRepository instance
    userRepository = UserRepository.instance;
  });

  group('UserRepository', () {
    test('get should return a UserModel when record exists', () async {
      // Arrange
      when(mockPostgrestResponse.data).thenReturn([
        {
          'id': 'test_user_id',
          'email': 'test@example.com',
          'display_name': 'Test User',
          'elo_rating': 1200,
          'games_played': 10,
          'games_won': 5,
          'games_lost': 3,
          'games_draw': 2,
          'created_at': DateTime.now().toIso8601String(),
          'last_login_at': DateTime.now().toIso8601String(),
        }
      ]);

      // Act
      final user = await userRepository.get('test_user_id');

      // Assert
      expect(user, isNotNull);
      expect(user?.uid, equals('test_user_id'));
      expect(user?.email, equals('test@example.com'));
      expect(user?.displayName, equals('Test User'));
      expect(user?.eloRating, equals(1200));
    });

    test('get should return null when record does not exist', () async {
      // Arrange
      when(mockPostgrestResponse.data).thenReturn([]);

      // Act
      final user = await userRepository.get('test_user_id');

      // Assert
      expect(user, isNull);
    });

    test('createUser should create a new user record', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.id).thenReturn('test_user_id');
      when(mockUser.email).thenReturn('test@example.com');

      // Act
      await userRepository.createUser(mockUser);

      // Assert
      verify(mockSupabaseQueryBuilder.insert(any)).called(1);
    });

    test('updateLastLogin should update last_login_at field', () async {
      // Act
      await userRepository.updateLastLogin('test_user_id');

      // Assert
      verify(mockSupabaseQueryBuilder.update(argThat(
        predicate((Map<String, dynamic> data) => data.containsKey('last_login_at'))
      ))).called(1);
    });

    test('updateEloRating should update elo_rating field', () async {
      // Act
      await userRepository.updateEloRating('test_user_id', 1250);

      // Assert
      verify(mockSupabaseQueryBuilder.update({'elo_rating': 1250})).called(1);
    });

    test('getTopPlayers should return a list of UserModel', () async {
      // Act
      final users = await userRepository.getTopPlayers(limit: 10);

      // Assert
      expect(users, isNotEmpty);
      expect(users.length, equals(1));
      expect(users.first.uid, equals('test_user_id'));
    });
  });
}
