import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/detection_provider.dart';
import '../widgets/app_widgets.dart';

class DetectScreen extends StatelessWidget {
  const DetectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final detection = context.watch<DetectionProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('AgroSpray AI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Crop Disease Detection', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text('Capture a leaf image or upload one from the gallery to detect the disease and see pesticide guidance.'),
            const SizedBox(height: 20),
            if (detection.selectedImage != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  detection.selectedImage!,
                  height: 260,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 260,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: const Center(child: Text('Leaf preview will appear here')),
              ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Camera',
                    onPressed: () => context.read<DetectionProvider>().pickImage(ImageSource.camera),
                    icon: Icons.photo_camera_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: 'Gallery',
                    onPressed: () => context.read<DetectionProvider>().pickImage(ImageSource.gallery),
                    icon: Icons.photo_library_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            AppButton(
              label: 'Analyze leaf',
              onPressed: detection.selectedImage == null ? null : () => context.read<DetectionProvider>().analyzeImage(),
              icon: Icons.search_rounded,
              loading: detection.loading,
            ),
            if (detection.error != null) ...[
              const SizedBox(height: 16),
              Text(detection.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
            if (detection.result != null) ...[
              const SizedBox(height: 20),
              ResultCard(title: 'Disease', value: detection.result!.disease, icon: Icons.bug_report_rounded),
              ResultCard(title: 'Confidence', value: '${(detection.result!.confidence * 100).toStringAsFixed(2)}%', icon: Icons.verified_rounded),
              ResultCard(title: 'Pesticide', value: detection.result!.pesticide, icon: Icons.medical_services_rounded),
              ResultCard(title: 'Dosage', value: detection.result!.dosage, icon: Icons.science_rounded),
              ResultCard(title: 'Safety', value: detection.result!.safety, icon: Icons.security_rounded),
              if (detection.result!.notes.isNotEmpty)
                ResultCard(title: 'Notes', value: detection.result!.notes, icon: Icons.notes_rounded),
            ],
          ],
        ),
      ),
    );
  }
}
