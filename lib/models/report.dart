class Report {
  Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    required this.fileUrl,
    required this.generatedAt,
    required this.summary,
  });

  final String id;
  final String userId;
  final String title;
  final String type;
  final String fileUrl;
  final DateTime generatedAt;
  final String summary;

  factory Report.fromMap(Map<String, dynamic> map, String id) {
    return Report(
      id: id,
      userId: map['userId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      type: map['type'] as String? ?? 'pdf',
      fileUrl: map['fileUrl'] as String? ?? '',
      generatedAt: DateTime.tryParse(map['generatedAt']?.toString() ?? '') ?? DateTime.now(),
      summary: map['summary'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'type': type,
      'fileUrl': fileUrl,
      'generatedAt': generatedAt.toIso8601String(),
      'summary': summary,
    };
  }
}
