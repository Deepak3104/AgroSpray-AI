class Crop {
  Crop({
    required this.id,
    required this.userId,
    required this.name,
    required this.variety,
    required this.fieldArea,
    required this.plantingDate,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final String variety;
  final double fieldArea;
  final DateTime plantingDate;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory Crop.fromMap(Map<String, dynamic> map, String id) {
    return Crop(
      id: id,
      userId: map['userId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      variety: map['variety'] as String? ?? '',
      fieldArea: (map['fieldArea'] as num? ?? 0).toDouble(),
      plantingDate: DateTime.tryParse(map['plantingDate']?.toString() ?? '') ?? DateTime.now(),
      status: map['status'] as String? ?? 'Active',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'variety': variety,
      'fieldArea': fieldArea,
      'plantingDate': plantingDate.toIso8601String(),
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
