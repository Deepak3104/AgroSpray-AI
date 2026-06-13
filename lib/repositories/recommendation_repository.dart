import 'package:agro_spray/models/pesticide_recommendation.dart';
import 'package:agro_spray/services/firestore_service.dart';

class RecommendationRepository {
  RecommendationRepository({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Future<PesticideRecommendation> getRecommendation({
    required String cropType,
    required String issue,
  }) async {
    final snapshot = await _firestoreService.collection('pesticide_recommendations').limit(100).get();
    final matches = snapshot.docs
        .map((doc) => PesticideRecommendation.fromMap(doc.data()))
        .where((item) =>
            item.cropType.toLowerCase() == cropType.toLowerCase() &&
            item.issue.toLowerCase().contains(issue.toLowerCase()))
        .toList();

    if (matches.isNotEmpty) {
      return matches.first;
    }

    return PesticideRecommendation(
      cropType: cropType,
      issue: issue,
      recommendedPesticide: 'Consult a certified agronomist',
      dosage: 'Follow the manufacturer label instructions.',
      precautions: 'Wear protective equipment and avoid spray drift.',
      notes: 'No exact match found in the recommendation catalog.',
    );
  }
}
