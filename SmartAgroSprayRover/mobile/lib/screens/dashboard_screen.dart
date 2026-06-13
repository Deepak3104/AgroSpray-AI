import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'auth/login_screen.dart';
import '../control/rover_control_screen.dart';
import '../control/camera_capture_screen.dart';
import '../control/ai_result_screen.dart';
import 'farmer_assistant_screen.dart';
import '../providers/app_state_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart AgroSpray Rover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AppStateProvider>().logout(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('ESP32 IP', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: state.esp32Ip,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter ESP32 IP address'),
              onChanged: (value) => state.updateEsp32Ip(value.trim()),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.directions_car),
              label: const Text('Rover Control'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RoverControlScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.camera_alt),
              label: const Text('Capture Crop Image'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraCaptureScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Farmer Assistant'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmerAssistantScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.analytics),
              label: const Text('AI Result'),
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiResultScreen())),
            ),
            const SizedBox(height: 24),
            Text('Pump Status: ${state.lastStatus}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
