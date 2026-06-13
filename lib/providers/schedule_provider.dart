import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/spray_schedule.dart';
import 'package:agro_spray/repositories/schedule_repository.dart';
import 'package:agro_spray/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {
  ScheduleProvider({required ScheduleRepository scheduleRepository}) : _scheduleRepository = scheduleRepository;

  final ScheduleRepository _scheduleRepository;
  final Uuid _uuid = const Uuid();
  String? _userId;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  List<SpraySchedule> _schedules = [];

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<SpraySchedule> get schedules => _schedules;

  void syncUser(String? userId) {
    if (_userId == userId) {
      return;
    }
    _userId = userId;
    if (_userId != null) {
      loadSchedules();
    } else {
      _schedules = [];
      notifyListeners();
    }
  }

  Future<void> loadSchedules() async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      _schedules = await _scheduleRepository.fetchSchedules(_userId!);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> saveSchedule({
    String? id,
    required String cropId,
    required String title,
    required DateTime scheduledAt,
    required int reminderMinutesBefore,
    required String status,
    required String notes,
  }) async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      final schedule = SpraySchedule(
        id: id ?? _uuid.v4(),
        userId: _userId!,
        cropId: cropId,
        title: title,
        scheduledAt: scheduledAt,
        reminderMinutesBefore: reminderMinutesBefore,
        status: status,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _scheduleRepository.saveSchedule(schedule);
      final reminderAt = scheduledAt.subtract(Duration(minutes: reminderMinutesBefore));
      await NotificationService.instance.scheduleReminder(
        id: schedule.id.hashCode & 0x7fffffff,
        title: title,
        body: 'Spray reminder for crop $cropId',
        scheduledAt: reminderAt.isAfter(DateTime.now()) ? reminderAt : scheduledAt,
      );
      await loadSchedules();
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteSchedule(String scheduleId) async {
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      await _scheduleRepository.deleteSchedule(scheduleId);
      _schedules.removeWhere((schedule) => schedule.id == scheduleId);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
