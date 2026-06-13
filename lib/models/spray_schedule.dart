class SpraySchedule {
  SpraySchedule({
    required this.id,
    required this.userId,
    required this.cropId,
    required this.title,
    required this.scheduledAt,
    required this.reminderMinutesBefore,
    required this.status,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String cropId;
  final String title;
  final DateTime scheduledAt;
  final int reminderMinutesBefore;
  final String status;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory SpraySchedule.fromMap(Map<String, dynamic> map, String id) {
    return SpraySchedule(
      id: id,
      userId: map['userId'] as String? ?? '',
      cropId: map['cropId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      scheduledAt: DateTime.tryParse(map['scheduledAt']?.toString() ?? '') ?? DateTime.now(),
      reminderMinutesBefore: map['reminderMinutesBefore'] as int? ?? 30,
      status: map['status'] as String? ?? 'Scheduled',
      notes: map['notes'] as String? ?? '',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'cropId': cropId,
      'title': title,
      'scheduledAt': scheduledAt.toIso8601String(),
      'reminderMinutesBefore': reminderMinutesBefore,
      'status': status,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
