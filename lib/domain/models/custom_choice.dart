class CustomChoice {
  const CustomChoice({
    required this.id,
    required this.label,
    this.enabled = true,
  });

  final String id;
  final String label;
  final bool enabled;

  CustomChoice copyWith({
    String? label,
    bool? enabled,
  }) {
    return CustomChoice(
      id: id,
      label: label ?? this.label,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'enabled': enabled,
      };

  factory CustomChoice.fromJson(Map<String, dynamic> json) {
    return CustomChoice(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
