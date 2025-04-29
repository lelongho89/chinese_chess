import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:chinese_chess/models/user_model.dart';
import 'package:chinese_chess/repositories/user_repository.dart';

import 'user_repository_test.mocks.dart';

@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  User,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockCollectionReference;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockQuerySnapshot mockQuerySnapshot;
  late MockQuery mockQuery;
  late UserRepository userRepository;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();
    mockQuery = MockQuery();

    // Mock FirebaseFirestore.instance
    when(mockFirestore.collection('users')).thenReturn(mockCollectionReference);
    
    // Mock collection reference
    when(mockCollectionReference.doc(any)).thenReturn(mockDocumentReference);
    
    // Mock document reference
    when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
    when(mockDocumentReference.set(any)).thenAnswer((_) async => {});
    when(mockDocumentReference.update(any)).thenAnswer((_) async => {});
    
    // Mock document snapshot
    when(mockDocumentSnapshot.exists).thenReturn(true);
    when(mockDocumentSnapshot.id).thenReturn('test_user_id');
    when(mockDocumentSnapshot.data()).thenReturn({
      'email': 'test@example.com',
      'displayName': 'Test User',
      'eloRating': 1200,
      'gamesPlayed': 10,
      'gamesWon': 5,
      'gamesLost': 3,
      'gamesDraw': 2,
      'createdAt': Timestamp.now(),
      'lastLoginAt': Timestamp.now(),
    });
    
    // Mock query
    when(mockCollectionReference.orderBy(any, descending: anyNamed('descending')))
        .thenReturn(mockQuery);
    when(mockQuery.limit(any)).thenReturn(mockQuery);
    when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
    
    // Mock query snapshot
    when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
    
    // Create UserRepository instance
    userRepository = UserRepository.instance;
  });

  group('UserRepository', () {
    test('get should return a UserModel when document exists', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(true);
      
      // Act
      final user = await userRepository.get('test_user_id');
      
      // Assert
      expect(user, isNotNull);
      expect(user?.uid, equals('test_user_id'));
      expect(user?.email, equals('test@example.com'));
      expect(user?.displayName, equals('Test User'));
      expect(user?.eloRating, equals(1200));
    });
    
    test('get should return null when document does not exist', () async {
      // Arrange
      when(mockDocumentSnapshot.exists).thenReturn(false);
      
      // Act
      final user = await userRepository.get('test_user_id');
      
      // Assert
      expect(user, isNull);
    });
    
    test('createUser should create a new user document', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test_user_id');
      when(mockUser.email).thenReturn('test@example.com');
      when(mockUser.displayName).thenReturn('Test User');
      
      // Act
      await userRepository.createUser(mockUser);
      
      // Assert
      verify(mockDocumentReference.set(any)).called(1);
    });
    
    test('updateLastLogin should update lastLoginAt field', () async {
      // Act
      await userRepository.updateLastLogin('test_user_id');
      
      // Assert
      verify(mockDocumentReference.update(argThat(
        predicate((Map<String, dynamic> data) => data.containsKey('lastLoginAt'))
      ))).called(1);
    });
    
    test('updateEloRating should update eloRating field', () async {
      // Act
      await userRepository.updateEloRating('test_user_id', 1250);
      
      // Assert
      verify(mockDocumentReference.update({'eloRating': 1250})).called(1);
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
