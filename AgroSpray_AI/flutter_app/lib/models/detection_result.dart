class DetectionResult {
  DetectionResult({
    required this.disease,
    required this.confidence,
    required this.pesticide,
    required this.dosage,
    required this.safety,
    required this.notes,
    required this.imagePath,
    this.createdAt,
  });

  final String disease;
  final double confidence;
  final String pesticide;
  final String dosage;
  final String safety;
  final String notes;
  final String imagePath;
  final DateTime? createdAt;

  Map<String, dynamic> toMap() {
    return {
      'disease': disease,
      'confidence': confidence,
      'pesticide': pesticide,
      'dosage': dosage,
      'safety': safety,
      'notes': notes,
      'imagePath': imagePath,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory DetectionResult.fromMap(Map<String, dynamic> map) {
    return DetectionResult(
      disease: map['disease'] as String? ?? '',
      confidence: (map['confidence'] as num? ?? 0).toDouble(),
      pesticide: map['pesticide'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      safety: map['safety'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
      imagePath: map['imagePath'] as String? ?? '',
      createdAt: map['createdAt'] == null ? null : DateTime.tryParse(map['createdAt'].toString()),
    );
  }

  DetectionResult copyWith({
    String? disease,
    double? confidence,
    String? pesticide,
    String? dosage,
    String? safety,
    String? notes,
    String? imagePath,
    DateTime? createdAt,
  }) {
    return DetectionResult(
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      pesticide: pesticide ?? this.pesticide,
      dosage: dosage ?? this.dosage,
      safety: safety ?? this.safety,
      notes: notes ?? this.notes,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
