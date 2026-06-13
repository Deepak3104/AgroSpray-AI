class DetectionResult {
  final String disease;
  final double confidence;
  final String severity;
  final int infectionPercentage;
  final String spray;
  final String pesticide;
  final String dosage;
  final String? notes;

  DetectionResult({
    required this.disease,
    required this.confidence,
    required this.severity,
    required this.infectionPercentage,
    required this.spray,
    required this.pesticide,
    required this.dosage,
    this.notes,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      disease: json['disease'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      severity: json['severity'] as String,
      infectionPercentage: json['infection_percentage'] as int,
      spray: json['spray'] as String,
      pesticide: json['pesticide'] as String,
      dosage: json['dosage'] as String,
      notes: json['notes'] as String?,
    );
  }
}
