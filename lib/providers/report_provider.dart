import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/report.dart';
import 'package:agro_spray/repositories/report_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ReportProvider extends ChangeNotifier {
  ReportProvider({required ReportRepository reportRepository}) : _reportRepository = reportRepository;

  final ReportRepository _reportRepository;
  final Uuid _uuid = const Uuid();
  String? _userId;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  List<Report> _reports = [];

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Report> get reports => _reports;

  void syncUser(String? userId) {
    if (_userId == userId) {
      return;
    }
    _userId = userId;
    if (_userId != null) {
      loadReports();
    } else {
      _reports = [];
      notifyListeners();
    }
  }

  Future<void> loadReports() async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      _reports = await _reportRepository.fetchReports(_userId!);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> createReport({required String title, required String summary}) async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      final report = Report(
        id: _uuid.v4(),
        userId: _userId!,
        title: title,
        type: 'pdf',
        fileUrl: '',
        generatedAt: DateTime.now(),
        summary: summary,
      );
      await _reportRepository.saveReport(report);
      await loadReports();
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }
}
