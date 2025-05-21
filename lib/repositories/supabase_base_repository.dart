import 'package:supabase_flutter/supabase_flutter.dart';

import '../global.dart';
import '../supabase_client.dart';

/// Base repository class for Supabase operations
abstract class SupabaseBaseRepository<T> {
  final String tableName;
  
  SupabaseBaseRepository(this.tableName);
  
  // Get a reference to the table
  SupabaseQueryBuilder get table => SupabaseClient.instance.database.from(tableName);
  
  // Convert a Supabase record to a model
  T fromSupabase(Map<String, dynamic> data, String id);
  
  // Convert a model to a Supabase record
  Map<String, dynamic> toSupabase(T model);
  
  // Get a record by ID
  Future<T?> get(String id) async {
    try {
      final response = await table
          .select()
          .eq('id', id)
          .maybeSingle();
      
      if (response != null) {
        return fromSupabase(response, id);
      }
      return null;
    } catch (e) {
      logger.severe('Error getting record: $e');
      rethrow;
    }
  }
  
  // Get all records
  Future<List<T>> getAll() async {
    try {
      final response = await table
          .select()
          .order('created_at', ascending: false);
      
      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error getting all records: $e');
      rethrow;
    }
  }
  
  // Create a new record
  Future<String> add(T model) async {
    try {
      final data = toSupabase(model);
      final response = await table
          .insert(data)
          .select();
      
      if (response.isNotEmpty) {
        return response.first['id'] as String;
      }
      throw Exception('Failed to create record');
    } catch (e) {
      logger.severe('Error adding record: $e');
      rethrow;
    }
  }
  
  // Update a record
  Future<void> update(String id, Map<String, dynamic> data) async {
    try {
      await table
          .update(data)
          .eq('id', id);
    } catch (e) {
      logger.severe('Error updating record: $e');
      rethrow;
    }
  }
  
  // Delete a record
  Future<void> delete(String id) async {
    try {
      await table
          .delete()
          .eq('id', id);
    } catch (e) {
      logger.severe('Error deleting record: $e');
      rethrow;
    }
  }
  
  // Set a record (create or update)
  Future<void> set(String id, T model) async {
    try {
      final data = toSupabase(model);
      final exists = await get(id) != null;
      
      if (exists) {
        await update(id, data);
      } else {
        data['id'] = id;
        await table.insert(data);
      }
    } catch (e) {
      logger.severe('Error setting record: $e');
      rethrow;
    }
  }
  
  // Query records
  Future<List<T>> query({
    required String field,
    required dynamic value,
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) async {
    try {
      var query = table
          .select()
          .eq(field, value)
          .order(orderBy, ascending: ascending);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final response = await query;
      
      return response.map((record) {
        final id = record['id'] as String;
        return fromSupabase(record, id);
      }).toList();
    } catch (e) {
      logger.severe('Error querying records: $e');
      rethrow;
    }
  }
  
  // Listen to changes in a record
  Stream<T?> listenToRecord(String id) {
    try {
      return table
          .select()
          .eq('id', id)
          .limit(1)
          .stream()
          .map((response) {
            if (response.isNotEmpty) {
              return fromSupabase(response.first, id);
            }
            return null;
          });
    } catch (e) {
      logger.severe('Error listening to record: $e');
      rethrow;
    }
  }
  
  // Listen to changes in all records
  Stream<List<T>> listenToAll({
    String orderBy = 'created_at',
    bool ascending = false,
    int? limit,
  }) {
    try {
      var query = table
          .select()
          .order(orderBy, ascending: ascending);
      
      if (limit != null) {
        query = query.limit(limit);
      }
      
      return query
          .stream()
          .map((response) {
            return response.map((record) {
              final id = record['id'] as String;
              return fromSupabase(record, id);
            }).toList();
          });
    } catch (e) {
      logger.severe('Error listening to all records: $e');
      rethrow;
    }
  }
}
