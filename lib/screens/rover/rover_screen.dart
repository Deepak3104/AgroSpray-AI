import 'dart:async';
import 'package:agro_spray/services/api_service.dart';
import 'package:flutter/material.dart';

class RoverScreen extends StatefulWidget {
  const RoverScreen({super.key});

  @override
  State<RoverScreen> createState() => _RoverScreenState();
}

class _RoverScreenState extends State<RoverScreen> {
  bool _connected = true;
  String _roverIp = '192.168.4.1';
  int _battery = 88;
  String _wifiStrength = 'Excellent';
  String _motorStatus = 'STOPPED';
  String _pumpStatus = 'OFF';
  bool _autoSprayMode = false;

  Timer? _telemetryTimer;
  final TextEditingController _ipController = TextEditingController(text: '192.168.4.1');

  @override
  void initState() {
    super.initState();
    _fetchStatus();
    // Refresh telemetry every 3 seconds
    _telemetryTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _fetchStatus();
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _ipController.dispose();
    super.dispose();
  }

  Future<void> _fetchStatus() async {
    final status = await ApiService.instance.getRoverStatus();
    if (status != null && mounted) {
      setState(() {
        _connected = status['connected'] ?? false;
        _battery = status['battery'] ?? 0;
        _motorStatus = status['motor_status'] ?? 'STOPPED';
        _pumpStatus = status['pump_status'] ?? 'OFF';
        _wifiStrength = status['wifi_strength'] ?? 'Good';
        _roverIp = status['ip'] ?? '192.168.4.1';
      });
    }
  }

  Future<void> _sendCommand(String command, String displayName) async {
    setState(() {
      if (command == 'stop') {
        _motorStatus = 'STOPPED';
      } else if (command == 'spray_on') {
        _pumpStatus = 'ON';
      } else if (command == 'spray_off') {
        _pumpStatus = 'OFF';
      } else {
        _motorStatus = displayName.toUpperCase();
      }
    });

    final success = await ApiService.instance.sendRoverCommand(command);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to execute command: $displayName. Check WiFi connection.'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),
        ),
      );
      _fetchStatus();
    }
  }

  Future<void> _emergencyStop() async {
    setState(() {
      _motorStatus = 'EMERGENCY STOP';
      _pumpStatus = 'OFF';
      _autoSprayMode = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🚨 EMERGENCY STOP SENT! halting all actions.'),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
      ),
    );

    // Send stop command and spray off command
    await ApiService.instance.sendRoverCommand('stop');
    await ApiService.instance.sendRoverCommand('spray_off');
    _fetchStatus();
  }

  void _updateIpAddress() {
    final ip = _ipController.text.trim();
    if (ip.isNotEmpty) {
      ApiService.instance.updateRoverUrl('http://$ip');
      setState(() {
        _roverIp = ip;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rover IP updated to: $ip')),
      );
    }
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
          title: const Text('🚜 Rover Control Center', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.green),
              onPressed: _fetchStatus,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Status Panel Card
            Card(
              color: const Color(0xFF111C13),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.green.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _connected ? Colors.green : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _connected ? 'ROVER ONLINE' : 'ROVER OFFLINE',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: _connected ? Colors.green : Colors.red,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'IP: $_roverIp',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    const Divider(height: 30, color: Colors.white10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatusIndicator(Icons.battery_4_bar_rounded, 'Battery', '$_battery%', Colors.green),
                        _buildStatusIndicator(Icons.wifi_rounded, 'WiFi Signal', _wifiStrength, Colors.blue),
                        _buildStatusIndicator(
                          _pumpStatus == 'ON' ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                          'Pump Status',
                          _pumpStatus,
                          _pumpStatus == 'ON' ? Colors.blue : Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // IP Configuration section
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF142417),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.settings_ethernet_rounded, color: Colors.green, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _ipController,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      decoration: const InputDecoration(
                        hintText: 'Enter Rover ESP32 IP',
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _updateIpAddress,
                    child: const Text('Update', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Manual Direction D-Pad
            const Center(
              child: Text(
                '🕹️ MANUAL CONTROL KEYPAD',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.2, fontSize: 13),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  children: [
                    // Outer Ring representation
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.02),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.green.withOpacity(0.1), width: 3),
                        ),
                      ),
                    ),
                    // Forward Button
                    Align(
                      alignment: Alignment.topCenter,
                      child: _buildDirectionButton(Icons.arrow_upward_rounded, 'forward', 'Forward'),
                    ),
                    // Left Button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: _buildDirectionButton(Icons.arrow_back_rounded, 'left', 'Left'),
                    ),
                    // Stop Button
                    Align(
                      alignment: Alignment.center,
                      child: GestureDetector(
                        onTap: () => _sendCommand('stop', 'Stop'),
                        child: Container(
                          width: 65,
                          height: 65,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C1919),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.red.withOpacity(0.4), width: 2),
                          ),
                          child: const Icon(Icons.stop_rounded, color: Colors.red, size: 32),
                        ),
                      ),
                    ),
                    // Right Button
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildDirectionButton(Icons.arrow_forward_rounded, 'right', 'Right'),
                    ),
                    // Backward Button
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: _buildDirectionButton(Icons.arrow_downward_rounded, 'backward', 'Backward'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                'Motor State: $_motorStatus',
                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15),
              ),
            ),
            const SizedBox(height: 24),
            // Pump Controller Row
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF122014),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 28),
                        const SizedBox(height: 8),
                        const Text('Pesticide Pump', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pumpStatus == 'ON' ? Colors.blue : const Color(0xFF1C2B20),
                                minimumSize: const Size(60, 40),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              onPressed: () => _sendCommand('spray_on', 'Spray ON'),
                              child: const Text('ON', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _pumpStatus == 'OFF' ? Colors.grey[800] : const Color(0xFF1C2B20),
                                minimumSize: const Size(60, 40),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              onPressed: () => _sendCommand('spray_off', 'Spray OFF'),
                              child: const Text('OFF', style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Auto Spray / Operation mode Card
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF141F1A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.green.withOpacity(0.15)),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.settings_suggest_rounded, color: Colors.green, size: 28),
                        const SizedBox(height: 8),
                        const Text('Automatic Mode', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Switch(
                          value: _autoSprayMode,
                          activeColor: Colors.green,
                          onChanged: (val) {
                            setState(() {
                              _autoSprayMode = val;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(val ? 'Automatic Spraying Mode Enabled' : 'Switched to Manual Control'),
                                backgroundColor: val ? Colors.green : Colors.grey[800],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Safety Emergency Stop Button
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
              ),
              onPressed: _emergencyStop,
              icon: const Icon(Icons.dangerous_rounded, size: 28),
              label: const Text(
                'EMERGENCY STOP',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(IconData icon, String title, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildDirectionButton(IconData icon, String command, String displayName) {
    return GestureDetector(
      onTap: () => _sendCommand(command, displayName),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: const Color(0xFF142417),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.green.withOpacity(0.3), width: 1.5),
        ),
        child: Icon(icon, color: Colors.green, size: 28),
      ),
    );
  }
}
