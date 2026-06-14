import 'dart:io';
import 'package:agro_spray/services/api_service.dart';
import 'package:agro_spray/services/local_storage_service.dart';
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
  
  static const Map<String, Map<String, String>> _uiTranslations = {
    'en-IN': {
      'welcome': 'Hello! I am your AI Farmer Assistant. Ask me anything about crop diseases, fertilizers, or Rover controls.',
      'hint': 'Type message or ask AI...',
      'scan_title': '📷 Scan Crop Disease',
      'scan_subtitle': 'Take leaf photo, analyze severity & automate spraying',
      'rover_status': '🚜 Rover status',
      'connected': 'Connected (WiFi)',
      'disconnected': 'Disconnected',
    },
    'hi-IN': {
      'welcome': 'नमस्ते! मैं आपका एआई किसान सहायक हूँ। मुझसे फसल के रोगों, उर्वरकों या रोवर नियंत्रणों के बारे में कुछ भी पूछें।',
      'hint': 'संदेश टाइप करें या एआई से पूछें...',
      'scan_title': '📷 फसल रोग स्कैन करें',
      'scan_subtitle': 'पत्ती का फोटो लें, संक्रमण की जांच करें और छिड़काव शुरू करें',
      'rover_status': '🚜 रोवर की स्थिति',
      'connected': 'कनेक्टेड (WiFi)',
      'disconnected': 'डिस्कनेक्टेड',
    },
    'ta-IN': {
      'welcome': 'வணக்கம்! நான் உங்கள் AI விவசாய உதவியாளர். பயிர் நோய்கள், உரங்கள் அல்லது ரோவர் கட்டுப்பாடுகள் பற்றி என்னிடம் எதையும் கேளுங்கள்.',
      'hint': 'செய்தியைத் தட்டச்சு செய்யவும்...',
      'scan_title': '📷 பயிர் நோயை ஸ்கேன் செய்க',
      'scan_subtitle': 'இலை புகைப்படத்தை எடுக்கவும், தீவிரத்தை பகுப்பாய்வு செய்து தெளிப்பினை தானியங்குபடுத்தவும்',
      'rover_status': '🚜 ரோவர் நிலை',
      'connected': 'இணைக்கப்பட்டுள்ளது (WiFi)',
      'disconnected': 'இணைக்கப்படவில்லை',
    },
    'te-IN': {
      'welcome': 'నమస్తే! నేను మీ AI రైతు సహాయకుడిని. పంట తెగుళ్లు, ఎరువులు లేదా రోవర్ నియంత్రణల గురించి ఏదైనా అడగండి.',
      'hint': 'సందేశాన్ని టైప్ చేయండి...',
      'scan_title': '📷 పంట తెగులు స్కాన్ చేయండి',
      'scan_subtitle': 'ఆకు ఫోటో తీయండి, తీవ్రతను విశ్లేషించి స్ప్రే చేయండి',
      'rover_status': '🚜 రోవర్ స్థితి',
      'connected': 'కనెక్ట్ చేయబడింది (WiFi)',
      'disconnected': 'డిస్కనెక్ట్ చేయబడింది',
    },
    'kn-IN': {
      'welcome': 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ AI ರೈತ ಸಹಾಯಕ. ಬೆಳೆ ರೋಗಗಳು, ರಸಗೊಬ್ಬರಗಳು ಅಥವಾ ರೋವರ್ ನಿಯಂತ್ರಣಗಳ ಬಗ್ಗೆ ಏನನ್ನಾದರೂ ಕೇಳಿ.',
      'hint': 'ಸಂದೇಶವನ್ನು ಟೈಪ್ ಮಾಡಿ...',
      'scan_title': '📷 ಬೆಳೆ ರೋಗ ಸ್ಕ್ಯಾನ್ ಮಾಡಿ',
      'scan_subtitle': 'ಎಲೆಯ ಫೋಟೋ ತೆಗೆಯಿರಿ, ತೀವ್ರತೆಯನ್ನು ವಿಶ್ಲೇಷಿಸಿ ಮತ್ತು ಸಿಂಪರಣೆ ಸ್ವಯಂಚಾಲิตಗೊಳಿಸಿ',
      'rover_status': '🚜 ರೋವರ್ ಸ್ಥಿತಿ',
      'connected': 'ಸಂಪರ್ಕಗೊಂಡಿದೆ (WiFi)',
      'disconnected': 'ಸಂಪರ್ಕ ಕಡಿತಗೊಂಡಿದೆ',
    },
    'ml-IN': {
      'welcome': 'ഹലോ! ഞാൻ നിങ്ങളുടെ AI കർഷക സഹായിയാണ്. വിള രോഗങ്ങൾ, വളങ്ങൾ അല്ലെങ്കിൽ റോവർ നിയന്ത്രണങ്ങൾ എന്നിവയെക്കുറിച്ച് ചോദിക്കുക.',
      'hint': 'സന്ദേശം ടൈപ്പ് ചെയ്യുക...',
      'scan_title': '📷 വിള രോഗം സ്കാൻ ചെയ്യുക',
      'scan_subtitle': 'ഇലയുടെ ഫോട്ടോ എടുക്കുക, അണുബാധ വിലയിరుത്തുക, തളിക്കൽ നടത്തുക',
      'rover_status': '🚜 റോവർ നില',
      'connected': 'കണക്റ്റ് ചെയ്‌തിരിക്കുന്നു (WiFi)',
      'disconnected': 'വിച്ഛേദിക്കപ്പെട്ടു',
    },
    'mr-IN': {
      'welcome': 'नमस्कार! मी तुमचा AI शेतकरी सहाय्यक आहे. मला पिकांचे रोग, खते किंवा रोवर नियंत्रणांबद्दल काहीही विचारा.',
      'hint': 'संदेश टाईप करा...',
      'scan_title': '📷 पीक रोग स्कॅन करा',
      'scan_subtitle': 'पानाचा फोटो घ्या, तीव्रतेचे विश्लेषण करा आणि फवारणी सुरू करा',
      'rover_status': '🚜 रोव्हरची स्थिती',
      'connected': 'कनेक्ट केलेले (WiFi)',
      'disconnected': 'डिस्कनेक्ट केलेले',
    },
    'gu-IN': {
      'welcome': 'નમસ્તે! હું તમારો AI ખેડૂત સહાયક છું. મને પાકના રોગો, ખાતરો અથવા રોવર નિયંત્રણો વિશે કંઈપણ પૂછો.',
      'hint': 'સંદેશ ટાઇપ કરો...',
      'scan_title': '📷 પાક રોગ સ્કેન કરો',
      'scan_subtitle': 'પાંદડાનો ફોટો લો, ગંભીરતા તપાસો અને છંટકાવ શરૂ કરો',
      'rover_status': '🚜 રોવરની સ્થિતિ',
      'connected': 'કનેક્ટેડ (WiFi)',
      'disconnected': 'ડિસ્કનેક્ટેડ',
    },
    'bn-IN': {
      'welcome': 'হ্যালো! আমি আপনার AI কৃষক সহকারী। ফসলের রোগ, সার বা রোভার নিয়ন্ত্রণ সম্পর্কে আমাকে কিছু জিজ্ঞাসা করুন।',
      'hint': 'বার্তা টাইপ করুন...',
      'scan_title': '📷 ফসল রোগ স্ক্যান করুন',
      'scan_subtitle': 'পাতার ছবি নিন, সংক্রমণ বিশ্লেষণ করুন এবং স্প্রে করুন',
      'rover_status': '🚜 রোভারের অবস্থা',
      'connected': 'সংযুক্ত (WiFi)',
      'disconnected': 'বিচ্ছিন্ন',
    },
    'pa-IN': {
      'welcome': 'ਸਤਿ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡਾ ਏਆਈ ਕਿਸਾਨ ਸਹਾਇਕ ਹਾਂ। ਫਸਲਾਂ ਦੀਆਂ ਬਿਮਾਰੀਆਂ, ਖਾਦਾਂ ਜਾਂ ਰੋਵਰ ਨਿਯੰਤਰਣ ਬਾਰੇ ਕੁਝ ਵੀ ਪੁੱਛੋ।',
      'hint': 'ਸੰਦੇਸ਼ ਲਿਖੋ...',
      'scan_title': '📷 ਫਸਲ ਦੀ ਬਿਮਾਰੀ ਸਕੈਨ ਕਰੋ',
      'scan_subtitle': 'ਪੱਤੇ ਦੀ ਫੋਟੋ ਲਓ, ਗੰਭੀਰਤਾ ਦਾ ਵਿਸ਼ਲੇਸ਼ਣ ਕਰੋ ਅਤੇ ਸਪਰੇਅ ਸ਼ੁਰੂ ਕਰੋ',
      'rover_status': '🚜 ਰੋਵਰ ਦੀ ਸਥਿਤੀ',
      'connected': 'ਕਨੈਕਟਡ (WiFi)',
      'disconnected': 'ਡਿਸਕਨੈਕਟਡ',
    },
  };

  late final List<Map<String, dynamic>> _messages;

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
    _messages = [
      {
        'text': _getTranslation('welcome', 'en-IN'),
        'isUser': false,
        'time': 'Just now',
      }
    ];
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    // Load saved backend URL
    final savedUrl = LocalStorageService.instance.getBackendUrl();
    if (savedUrl != null) {
      ApiService.instance.updateBackendUrl(savedUrl);
    }
    
    _fetchRoverStatus();
  }

  String _getTranslation(String key, String langCode) {
    return _uiTranslations[langCode]?[key] ?? _uiTranslations['en-IN']![key]!;
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

    final reply = await ApiService.instance.sendChatMessage(text, _selectedLanguage);
    
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

  void _showBackendSettingsDialog() {
    final controller = TextEditingController(text: ApiService.backendBaseUrl);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF111A12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Backend Connection Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the local IP address of your host machine running the FastAPI backend so your physical phone can connect:',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'FastAPI Backend URL',
                  labelStyle: TextStyle(color: Colors.green),
                  hintText: 'e.g. http://192.168.1.10:8000',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () async {
                final url = controller.text.trim();
                if (url.isNotEmpty) {
                  ApiService.instance.updateBackendUrl(url);
                  await LocalStorageService.instance.saveBackendUrl(url);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Backend URL set to: $url')),
                  );
                  _fetchRoverStatus();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
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
                  setState(() {
                    _selectedLanguage = val;
                    // Translate initial welcome greeting instantly in list
                    if (_messages.length == 1 && !_messages[0]['isUser']) {
                      _messages[0]['text'] = _getTranslation('welcome', val);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to: ${_getLanguageName(val)}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.green),
              onPressed: _showBackendSettingsDialog,
            ),
            const SizedBox(width: 4),
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
                      child: Row(
                        children: [
                          const Icon(Icons.camera_alt_rounded, color: Colors.green, size: 40),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getTranslation('scan_title', _selectedLanguage),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getTranslation('scan_subtitle', _selectedLanguage),
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, color: Colors.green, size: 16),
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
                                Text(
                                  _getTranslation('rover_status', _selectedLanguage),
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _roverConnected
                                      ? _getTranslation('connected', _selectedLanguage)
                                      : _getTranslation('disconnected', _selectedLanguage),
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _roverConnected ? Colors.green : Colors.red,
                                  ),
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
                              decoration: InputDecoration(
                                hintText: _getTranslation('hint', _selectedLanguage),
                                hintStyle: const TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
