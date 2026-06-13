import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class AiResultScreen extends StatelessWidget {
  const AiResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final result = state.detectionResult;

    return Scaffold(
      appBar: AppBar(title: const Text('AI Result')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: result == null
            ? const Center(child: Text('No result available yet.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Disease: ${result.disease}', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Text('Confidence: ${result.confidence.toStringAsFixed(2)}%', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Severity: ${result.severity}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Infection: ${result.infectionPercentage}%', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Recommended Pesticide: ${result.pesticide}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 8),
                  Text('Dosage: ${result.dosage}', style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  ElevatedButton(onPressed: () => context.read<AppStateProvider>().sprayOn(), child: const Text('Start Spray')),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: () => context.read<AppStateProvider>().sprayOff(), child: const Text('Stop Spray')),
                  const SizedBox(height: 16),
                  Text('Last pump status: ${state.lastStatus}'),
                ],
              ),
      ),
    );
  }
}
