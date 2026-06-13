import 'package:agro_spray/core/constants/app_constants.dart';
import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/crop.dart';
import 'package:agro_spray/repositories/crop_repository.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class CropProvider extends ChangeNotifier {
  CropProvider({required CropRepository cropRepository}) : _cropRepository = cropRepository;

  final CropRepository _cropRepository;
  final Uuid _uuid = const Uuid();
  String? _userId;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  List<Crop> _crops = [];

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<Crop> get crops => _crops;

  void syncUser(String? userId) {
    if (_userId == userId) {
      return;
    }
    _userId = userId;
    if (_userId != null) {
      loadCrops();
    } else {
      _crops = [];
      notifyListeners();
    }
  }

  Future<void> loadCrops() async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      _crops = await _cropRepository.fetchCrops(_userId!);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }

  Future<void> saveCrop({
    String? id,
    DateTime? createdAt,
    required String name,
    required String variety,
    required double fieldArea,
    required DateTime plantingDate,
    required String status,
    required String notes,
  }) async {
    if (_userId == null) {
      return;
    }
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      final crop = Crop(
        id: id ?? _uuid.v4(),
        userId: _userId!,
        name: name,
        variety: variety,
        fieldArea: fieldArea,
        plantingDate: plantingDate,
        status: status,
        notes: notes,
        createdAt: createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _cropRepository.saveCrop(crop);
      await loadCrops();
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> deleteCrop(String cropId) async {
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      await _cropRepository.deleteCrop(cropId);
      _crops.removeWhere((crop) => crop.id == cropId);
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
