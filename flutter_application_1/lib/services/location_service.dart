import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/location.dart';

/// Everything the app needs to read and write `locations` rows.
/// The rest of the app should talk to this class, never to
/// Supabase.instance.client directly.
class LocationService {
  final SupabaseClient _client = Supabase.instance.client;
  static const String _table = 'locations';

  /// Fetches every saved location, oldest first.
  Future<List<Location>> fetchLocations() async {
    final data = await _client.from(_table).select().order('created_at');
    return (data as List)
        .map((row) => Location.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Inserts a new location and returns the row Supabase created
  /// (so you get back the auto-generated id and created_at).
  Future<Location> addLocation({
    required String name,
    String? description,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client
        .from(_table)
        .insert({
          'name': name,
          'description': description,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();
    return Location.fromJson(response);
  }

  /// Deletes a location by its id.
  Future<void> deleteLocation(int id) async {
    await _client.from(_table).delete().eq('id', id);
  }

  /// Updates an existing location with new values.
  Future<void> updateLocation(Location location) async {
    await _client
        .from(_table)
        .update(location.toJson())
        .eq('id', location.id);
  }

  /// Live-updating stream of all locations — emits a new list
  /// automatically whenever a row is added, changed, or removed
  /// by anyone. Useful later for keeping map markers in sync
  /// without manually re-fetching.
  Stream<List<Location>> watchLocations() {
    return _client
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map(
          (rows) => rows.map((row) => Location.fromJson(row)).toList(),
        );
  }
}