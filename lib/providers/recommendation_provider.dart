import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/pesticide_recommendation.dart';
import 'package:agro_spray/repositories/recommendation_repository.dart';
import 'package:flutter/material.dart';

class RecommendationProvider extends ChangeNotifier {
  RecommendationProvider({required RecommendationRepository recommendationRepository})
      : _recommendationRepository = recommendationRepository;

  final RecommendationRepository _recommendationRepository;
  RequestStatus _status = RequestStatus.idle;
  String? _errorMessage;
  String? _userId;
  PesticideRecommendation? _recommendation;

  RequestStatus get status => _status;
  String? get errorMessage => _errorMessage;
  PesticideRecommendation? get recommendation => _recommendation;

  void syncUser(String? userId) {
    _userId = userId;
  }

  Future<void> searchRecommendation({required String cropType, required String issue}) async {
    _status = RequestStatus.loading;
    notifyListeners();
    try {
      _recommendation = await _recommendationRepository.getRecommendation(
        cropType: cropType,
        issue: issue,
      );
      _status = RequestStatus.success;
    } catch (error) {
      _status = RequestStatus.error;
      _errorMessage = error.toString();
    }
    notifyListeners();
  }
}
