import 'dart:io';
import 'package:agro_spray/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  State<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [
    {
      'text': 'Hello! I am your AI Farmer Assistant. Ask me anything about crop diseases, fertilizers, or Rover controls.',
      'isUser': false,
      'time': 'Just now',
    }
  ];

  bool _isLoading = false;
  bool _isRecording = false;
  String _selectedLanguage = 'en-IN';

  // Rover state representation
  bool _roverConnected = true;
  int _roverBattery = 88;
  String _roverPumpStatus = 'OFF';

  late AnimationController _waveController;

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'code': 'en-IN'},
    {'name': 'Hindi (हिंदी)', 'code': 'hi-IN'},
    {'name': 'Tamil (தமிழ்)', 'code': 'ta-IN'},
    {'name': 'Telugu (తెలుగు)', 'code': 'te-IN'},
    {'name': 'Kannada (ಕನ್ನಡ)', 'code': 'kn-IN'},
    {'name': 'Malayalam (മലയാളം)', 'code': 'ml-IN'},
    {'name': 'Marathi (मराठी)', 'code': 'mr-IN'},
    {'name': 'Gujarati (ગુજરાતી)', 'code': 'gu-IN'},
    {'name': 'Bengali (বাংলা)', 'code': 'bn-IN'},
    {'name': 'Punjabi (ਪੰਜਾਬੀ)', 'code': 'pa-IN'},
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchRoverStatus();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _fetchRoverStatus() async {
    final status = await ApiService.instance.getRoverStatus();
    if (status != null && mounted) {
      setState(() {
        _roverConnected = status['connected'] ?? false;
        _roverBattery = status['battery'] ?? 0;
        _roverPumpStatus = status['pump_status'] ?? 'OFF';
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();
    setState(() {
      _messages.add({
        'text': text,
        'isUser': true,
        'time': _formatTime(),
      });
      _isLoading = true;
    });
    _scrollToBottom();

    final reply = await ApiService.instance.sendChatMessage(text);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
        _messages.add({
          'text': reply ?? 'I am sorry, I am having trouble connecting to the AI brain right now.',
          'isUser': false,
          'time': _formatTime(),
        });
      });
      _scrollToBottom();
    }
  }

  Future<void> _startVoiceAssistant() async {
    setState(() {
      _isRecording = true;
    });
    _waveController.repeat(reverse: true);

    // Simulate voice recording for 3 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;
    _waveController.stop();
    setState(() {
      _isRecording = false;
      _isLoading = true;
      _messages.add({
        'text': '🎙️ [Voice message sent in ${_getLanguageName(_selectedLanguage)}]',
        'isUser': true,
        'time': _formatTime(),
      });
    });
    _scrollToBottom();

    // Call voice chat API with a simulated audio file or fallback
    // Since we are in an emulator/device, we create a temporary file to send.
    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/temp_voice.wav');
    await tempFile.writeAsString('mock audio bytes');

    final result = await ApiService.instance.sendVoiceChat(tempFile, _selectedLanguage);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _messages.add({
            'text': '🗣️ Transcribed: "${result['transcript']}"\n\n🤖 AI: ${result['response']}',
            'isUser': false,
            'time': _formatTime(),
          });
        } else {
          _messages.add({
            'text': 'I heard you, but I could not convert your voice to text. Please check your internet or try again.',
            'isUser': false,
            'time': _formatTime(),
          });
        }
      });
      _scrollToBottom();
    }
  }

  Future<void> _scanCropDisease() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    
    if (image == null) return;

    // Show Scanning Modal
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          backgroundColor: Color(0xFF162218),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Colors.green),
                SizedBox(height: 20),
                Text(
                  'Scanning Crop Disease...',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Running AI Infection Severity modules',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      },
    );

    final result = await ApiService.instance.detectDisease(File(image.path));
    if (mounted) {
      Navigator.pop(context); // Close Scanning Modal
    }

    if (result == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to analyze the leaf. Please try again.')),
        );
      }
      return;
    }

    // Display Disease results
    if (mounted) {
      _showScanResults(result);
    }
  }

  void _showScanResults(Map<String, dynamic> result) {
    final disease = result['disease'] ?? 'Unknown Disease';
    final confidence = result['confidence'] ?? '0.0%';
    final severity = result['severity'] ?? 0.0;
    final pesticide = result['pesticide'] ?? 'N/A';
    final sprayRecommendation = result['spray_recommendation'] ?? 'N/A';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF121B13),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.eco_rounded, color: Colors.green),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  disease,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildResultRow('Confidence Score', confidence, Colors.green),
              _buildResultRow('Infection Severity', '$severity%', severity > 50.0 ? Colors.red : Colors.orange),
              _buildResultRow('Recommended Pesticide', pesticide, Colors.white),
              const SizedBox(height: 12),
              const Text('Spray Advice:', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
              Text(
                sprayRecommendation,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.grey)),
            ),
            if (severity > 50.0)
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () {
                  Navigator.pop(context);
                  _showAutoSprayPrompt(pesticide, severity);
                },
                child: const Text('Start Spraying'),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              )
          ],
        );
      },
    );
  }

  void _showAutoSprayPrompt(String pesticide, double severity) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1E1414),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text(
                'Auto Spray Action Required',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'High infection detected ($severity%).',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
              const SizedBox(height: 8),
              Text(
                'Recommended pesticide: $pesticide.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              const SizedBox(height: 12),
              const Text(
                'Do you want to start spraying automatically using the Rover?',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                Navigator.pop(context);
                _triggerSprayOn();
              },
              child: const Text('START SPRAY'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _triggerSprayOn() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sending spray command to Rover...')),
    );
    final success = await ApiService.instance.sendRoverCommand('spray_on');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Rover has started spraying successfully!' : 'Failed to connect to Rover WiFi.'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      _fetchRoverStatus();
    }
  }

  Widget _buildResultRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  String _formatTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getLanguageName(String code) {
    return _languages.firstWhere((lang) => lang['code'] == code)['name'] ?? 'English';
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0C120D),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E4620),
          brightness: Brightness.dark,
          primary: const Color(0xFF388E3C),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0F1A11),
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('🌱 AI Farmer Assistant', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green)),
              Text('Powered by Gemini 2.5 Flash', style: TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          actions: [
            DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: const Color(0xFF121F14),
              underline: const SizedBox(),
              icon: const Icon(Icons.language_rounded, color: Colors.green),
              items: _languages.map((lang) {
                return DropdownMenuItem(
                  value: lang['code'],
                  child: Text(
                    lang['name']!,
                    style: const TextStyle(fontSize: 12, color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() => _selectedLanguage = val);
                }
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            // Rover Control & Disease Detector header section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  // Disease detection card
                  GestureDetector(
                    onTap: _scanCropDisease,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF142F18), Color(0xFF0B1B0D)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.camera_alt_rounded, color: Colors.green, size: 40),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '📷 Scan Crop Disease',
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Take leaf photo, analyze severity & automate spraying',
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.green, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Rover status widget card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF111A12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.15)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.precision_manufacturing_rounded,
                              color: _roverConnected ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('🚜 Rover status', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text(
                                  _roverConnected ? 'Connected (WiFi)' : 'Disconnected',
                                  style: TextStyle(fontSize: 11, color: _roverConnected ? Colors.green : Colors.red),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(Icons.battery_5_bar_rounded, size: 16, color: _roverBattery > 50 ? Colors.green : Colors.orange),
                            const SizedBox(width: 4),
                            Text('$_roverBattery%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _roverPumpStatus == 'ON' ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Pump: $_roverPumpStatus',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _roverPumpStatus == 'ON' ? Colors.blue : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Chat Area
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  final isUser = msg['isUser'] as bool;
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.75,
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser ? const Color(0xFF1E3A24) : const Color(0xFF1E1E24),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(isUser ? 16 : 0),
                          bottomRight: Radius.circular(isUser ? 0 : 16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg['text']!,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              msg['time']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green),
                  ),
                ),
              ),
            // Voice Wave Overlay when recording
            if (_isRecording)
              Container(
                color: Colors.black.withOpacity(0.85),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🎙️ Listening...', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text('Speak in ${_getLanguageName(_selectedLanguage)} now', style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            double height = 15.0 + (index % 2 == 0 ? _waveController.value * 40 : (1.0 - _waveController.value) * 35);
                            return Container(
                              width: 8,
                              height: height,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tapping stops and analyzes with Sarvam Speech-to-Text', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            // Input Bar
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0xFF0F1611),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF17241A),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              _isRecording ? Icons.stop_circle_rounded : Icons.mic_rounded,
                              color: _isRecording ? Colors.red : Colors.green,
                            ),
                            onPressed: () {
                              if (_isRecording) {
                                // Handled automatically by simulation timeout, or stop it early
                              } else {
                                _startVoiceAssistant();
                              }
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Type message or ask AI...',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 8),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.green),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
