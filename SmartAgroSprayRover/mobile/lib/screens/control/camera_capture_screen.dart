import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state_provider.dart';

class CameraCaptureScreen extends StatefulWidget {
  const CameraCaptureScreen({super.key});

  @override
  State<CameraCaptureScreen> createState() => _CameraCaptureScreenState();
}

class _CameraCaptureScreenState extends State<CameraCaptureScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _captureImage() async {
    final picked = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (picked != null) {
      context.read<AppStateProvider>().setCapturedImage(File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Capture Crop Image')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (state.capturedImage != null)
              Image.file(state.capturedImage!, height: 300, fit: BoxFit.cover)
            else
              Container(height: 300, color: Colors.grey[200], child: const Center(child: Text('No image captured'))),
            const SizedBox(height: 24),
            ElevatedButton.icon(icon: const Icon(Icons.camera_alt), label: const Text('Capture Image'), onPressed: _captureImage),
            const SizedBox(height: 16),
            ElevatedButton.icon(icon: const Icon(Icons.cloud_upload), label: const Text('Upload to Backend'), onPressed: state.capturedImage == null ? null : () => context.read<AppStateProvider>().submitImage()),
          ],
        ),
      ),
    );
  }
}
