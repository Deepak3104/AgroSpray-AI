import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/screens/crop/crop_form_screen.dart';
import 'package:agro_spray/providers/crop_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CropHistoryScreen extends StatelessWidget {
  const CropHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cropProvider = context.watch<CropProvider>();
    final crops = cropProvider.crops;

    return Scaffold(
      appBar: AppBar(title: const Text('Crop History')),
      body: cropProvider.status == RequestStatus.loading && crops.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: crops.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final crop = crops[index];
                return Dismissible(
                  key: ValueKey(crop.id),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    color: Colors.red.withValues(alpha: 0.2),
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => context.read<CropProvider>().deleteCrop(crop.id),
                  child: Card(
                    child: ListTile(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => CropFormScreen(crop: crop)),
                      ),
                      title: Text(crop.name),
                      subtitle: Text('${crop.variety} • ${crop.fieldArea} acres • ${crop.status}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
