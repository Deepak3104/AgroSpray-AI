import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class RoverControlScreen extends StatelessWidget {
  const RoverControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Rover Control')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('ESP32 IP: ${state.esp32Ip}', style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => state.sendRoverCommand('forward'), child: const Text('Forward')),
                ElevatedButton(onPressed: () => state.sendRoverCommand('backward'), child: const Text('Backward')),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(onPressed: () => state.sendRoverCommand('left'), child: const Text('Left')),
                ElevatedButton(onPressed: () => state.sendRoverCommand('right'), child: const Text('Right')),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => state.sendRoverCommand('stop'), child: const Text('Stop')),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => state.sendRoverCommand('status'), child: const Text('Check Status')),
            const SizedBox(height: 16),
            Text('Status: ${state.lastStatus}'),
          ],
        ),
      ),
    );
  }
}
