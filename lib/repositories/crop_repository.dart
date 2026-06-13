import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/models/crop.dart';
import 'package:agro_spray/services/firestore_service.dart';

class CropRepository {
  CropRepository({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Future<List<Crop>> fetchCrops(String userId) async {
    final snapshot = await _firestoreService
        .collection(AppConstants.cropsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Crop.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveCrop(Crop crop) {
    return _firestoreService.setDocument(
      collectionPath: AppConstants.cropsCollection,
      documentId: crop.id,
      data: crop.toMap(),
    );
  }

  Future<void> deleteCrop(String cropId) {
    return _firestoreService.deleteDocument(
      collectionPath: AppConstants.cropsCollection,
      documentId: cropId,
    );
  }
}
