class PlayerProfile {
  const PlayerProfile({
    required this.id,
    required this.name,
    required this.isGuest,
    this.gameRatings = const <String, double>{},
  });

  final String id;
  final String name;
  final bool isGuest;

  // Reserved for the next feature: a player can have a different rating
  // for every game without requiring a storage migration later.
  final Map<String, double> gameRatings;

  PlayerProfile copyWith({
    String? name,
    bool? isGuest,
    Map<String, double>? gameRatings,
  }) {
    return PlayerProfile(
      id: id,
      name: name ?? this.name,
      isGuest: isGuest ?? this.isGuest,
      gameRatings: gameRatings ?? this.gameRatings,
    );
  }

  Map<String, Object> toJson() => {
        'id': id,
        'name': name,
        'gameRatings': gameRatings,
      };

  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    final ratings = <String, double>{};
    final rawRatings = json['gameRatings'];
    if (rawRatings is Map<String, dynamic>) {
      for (final entry in rawRatings.entries) {
        final value = entry.value;
        if (value is num) {
          ratings[entry.key] = value.toDouble();
        }
      }
    }

    return PlayerProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      isGuest: false,
      gameRatings: ratings,
    );
  }
}
