/// Represents one row from the `locations` table in Supabase.
class Location {
  final int id;
  final String name;
  final String? description;
  final double latitude;
  final double longitude;
  final DateTime createdAt;

  Location({
    required this.id,                             //konstruktor
    required this.name,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
  });

  /// Builds a [Location] from the raw map Supabase returns for a row.
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this object back into a map for sending to Supabase.
  /// `id` and `created_at` are left out on purpose — the database
  /// assigns those itself.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}