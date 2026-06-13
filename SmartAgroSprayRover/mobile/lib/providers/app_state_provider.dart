import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/chat_message.dart';
import '../models/detection_result.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../services/esp32_service.dart';

class AppStateProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String _esp32Ip = '';
  String _lastStatus = 'disconnected';
  DetectionResult? _detectionResult;
  File? _capturedImage;
  List<ChatMessage> _chatHistory = [];
  String _chatLanguage = 'en';

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String get esp32Ip => _esp32Ip;
  String get lastStatus => _lastStatus;
  DetectionResult? get detectionResult => _detectionResult;
  File? get capturedImage => _capturedImage;
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);
  String get chatLanguage => _chatLanguage;

  void updateEsp32Ip(String ip) {
    _esp32Ip = ip;
    notifyListeners();
  }

  void setCapturedImage(File image) {
    _capturedImage = image;
    notifyListeners();
  }

  void updateChatLanguage(String language) {
    _chatLanguage = language;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoggedIn = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> sendRoverCommand(String command) async {
    if (_esp32Ip.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    _lastStatus = await Esp32Service.sendCommand(_esp32Ip, command);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> submitImage() async {
    if (_capturedImage == null) return;
    _isLoading = true;
    notifyListeners();
    final result = await ApiService.uploadImage(_capturedImage!);
    _detectionResult = result;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sprayOn() async {
    if (_esp32Ip.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    _lastStatus = await Esp32Service.sendCommand(_esp32Ip, 'spray_on');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sprayOff() async {
    if (_esp32Ip.isEmpty) return;
    _isLoading = true;
    notifyListeners();
    _lastStatus = await Esp32Service.sendCommand(_esp32Ip, 'spray_off');
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendChatMessage(String message) async {
    _isLoading = true;
    notifyListeners();
    try {
      _chatHistory.add(ChatMessage(text: message, isUser: true, language: _chatLanguage));
      final responseText = await ChatService.sendChatMessage(message, _chatLanguage);
      _chatHistory.add(ChatMessage(text: responseText, isUser: false, language: _chatLanguage));
    } catch (e) {
      _chatHistory.add(ChatMessage(text: 'Error: $e', isUser: false, language: _chatLanguage));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
