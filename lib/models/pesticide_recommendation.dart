class PesticideRecommendation {
  PesticideRecommendation({
    required this.cropType,
    required this.issue,
    required this.recommendedPesticide,
    required this.dosage,
    required this.precautions,
    required this.notes,
  });

  final String cropType;
  final String issue;
  final String recommendedPesticide;
  final String dosage;
  final String precautions;
  final String notes;

  factory PesticideRecommendation.fromMap(Map<String, dynamic> map) {
    return PesticideRecommendation(
      cropType: map['cropType'] as String? ?? '',
      issue: map['issue'] as String? ?? '',
      recommendedPesticide: map['recommendedPesticide'] as String? ?? '',
      dosage: map['dosage'] as String? ?? '',
      precautions: map['precautions'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cropType': cropType,
      'issue': issue,
      'recommendedPesticide': recommendedPesticide,
      'dosage': dosage,
      'precautions': precautions,
      'notes': notes,
    };
  }
}
