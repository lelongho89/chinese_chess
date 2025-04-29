import 'package:cloud_firestore/cloud_firestore.dart';

import '../global.dart';

/// Base repository class for Firestore operations
abstract class BaseRepository<T> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String collectionPath;
  
  BaseRepository(this.collectionPath);
  
  // Get a reference to the collection
  CollectionReference get collection => _firestore.collection(collectionPath);
  
  // Convert a Firestore document to a model
  T fromFirestore(DocumentSnapshot doc);
  
  // Convert a model to a Firestore document
  Map<String, dynamic> toFirestore(T model);
  
  // Get a document by ID
  Future<T?> get(String id) async {
    try {
      final doc = await collection.doc(id).get();
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting document: $e');
      rethrow;
    }
  }
  
  // Get all documents
  Future<List<T>> getAll() async {
    try {
      final snapshot = await collection.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      logger.severe('Error getting all documents: $e');
      rethrow;
    }
  }
  
  // Add a new document
  Future<String> add(T model) async {
    try {
      final docRef = await collection.add(toFirestore(model));
      return docRef.id;
    } catch (e) {
      logger.severe('Error adding document: $e');
      rethrow;
    }
  }
  
  // Set a document with a specific ID
  Future<void> set(String id, T model) async {
    try {
      await collection.doc(id).set(toFirestore(model));
    } catch (e) {
      logger.severe('Error setting document: $e');
      rethrow;
    }
  }
  
  // Update a document
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await collection.doc(id).update(data);
    } catch (e) {
      logger.severe('Error updating document: $e');
      rethrow;
    }
  }
  
  // Delete a document
  Future<void> delete(String id) async {
    try {
      await collection.doc(id).delete();
    } catch (e) {
      logger.severe('Error deleting document: $e');
      rethrow;
    }
  }
  
  // Query documents
  Future<List<T>> query(Query Function(CollectionReference) queryBuilder) async {
    try {
      final query = queryBuilder(collection);
      final snapshot = await query.get();
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    } catch (e) {
      logger.severe('Error querying documents: $e');
      rethrow;
    }
  }
  
  // Listen to a document
  Stream<T?> listen(String id) {
    return collection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return fromFirestore(doc);
      }
      return null;
    });
  }
  
  // Listen to a query
  Stream<List<T>> listenToQuery(Query Function(CollectionReference) queryBuilder) {
    final query = queryBuilder(collection);
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => fromFirestore(doc)).toList();
    });
  }
}
