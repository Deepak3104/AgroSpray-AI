import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/models/spray_schedule.dart';
import 'package:agro_spray/services/firestore_service.dart';

class ScheduleRepository {
  ScheduleRepository({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Future<List<SpraySchedule>> fetchSchedules(String userId) async {
    final snapshot = await _firestoreService
        .collection(AppConstants.schedulesCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('scheduledAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => SpraySchedule.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveSchedule(SpraySchedule schedule) {
    return _firestoreService.setDocument(
      collectionPath: AppConstants.schedulesCollection,
      documentId: schedule.id,
      data: schedule.toMap(),
    );
  }

  Future<void> deleteSchedule(String scheduleId) {
    return _firestoreService.deleteDocument(
      collectionPath: AppConstants.schedulesCollection,
      documentId: scheduleId,
    );
  }
}
