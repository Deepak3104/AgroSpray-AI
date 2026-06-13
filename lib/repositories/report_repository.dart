import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/models/report.dart';
import 'package:agro_spray/services/firestore_service.dart';

class ReportRepository {
  ReportRepository({required FirestoreService firestoreService}) : _firestoreService = firestoreService;

  final FirestoreService _firestoreService;

  Future<List<Report>> fetchReports(String userId) async {
    final snapshot = await _firestoreService
        .collection(AppConstants.reportsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('generatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Report.fromMap(doc.data(), doc.id)).toList();
  }

  Future<void> saveReport(Report report) {
    return _firestoreService.setDocument(
      collectionPath: AppConstants.reportsCollection,
      documentId: report.id,
      data: report.toMap(),
    );
  }
}
