class LocationSuggestion {
  final String name;
  final String country;
  final String? state;
  final double lat;
  final double lon;
  final String displayName;

  LocationSuggestion({
    required this.name,
    required this.country,
    this.state,
    required this.lat,
    required this.lon,
  }) : displayName = state != null ? '$name, $state, $country' : '$name, $country';

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      state: json['state'],
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'state': state,
      'lat': lat,
      'lon': lon,
    };
  }
}