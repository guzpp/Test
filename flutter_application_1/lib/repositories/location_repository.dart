import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/location.dart';
import '../services/location_service.dart';

/// Thrown by [LocationRepository] when a fetch fails, carrying a
/// message that's safe to show directly in the UI — unlike a raw
/// Supabase exception, which might expose technical detail.
class LocationFetchException implements Exception {
  final String message;
  LocationFetchException(this.message);

  @override
  String toString() => message;
}

/// The layer responsible for fetch requests. It sits between
/// [LocationService] (which only knows how to talk to Supabase) and
/// the UI (which should never see a Supabase-specific error type).
/// Its job: make the request, and turn anything that goes wrong into
/// a predictable [LocationFetchException].
class LocationRepository {
  final LocationService _service;

  /// Accepting the service as an optional constructor argument
  /// (instead of creating it internally) means a test can pass in a
  /// fake LocationService later, without touching this class.
  LocationRepository({LocationService? service})
      : _service = service ?? LocationService();

  /// Fetches every saved location.
  /// Throws a [LocationFetchException] with a readable message if
  /// the request fails for any reason.
  Future<List<Location>> getAllLocations() async {
    try {
      return await _service.fetchLocations();
    } on PostgrestException catch (e) {
      // A PostgrestException comes from Supabase itself — e.g. a
      // missing table, a bad column name, or an RLS policy blocking
      // the request. e.message is Supabase's own explanation.
      throw LocationFetchException('Could not load locations: ${e.message}');
    } catch (e) {
      // Anything else (no internet, a timeout, etc.) falls here.
      // We deliberately don't expose the raw error to the UI.
      throw LocationFetchException(
        'Something went wrong while loading locations. Check your connection.',
      );
    }
  }

  /// Live-updating version of the same fetch, with the same error
  /// handling applied to whatever the stream emits.
  Stream<List<Location>> watchAllLocations() {
    return _service.watchLocations().handleError((error) {
      throw LocationFetchException(
        'Lost connection while watching locations.',
      );
    });
  }
}