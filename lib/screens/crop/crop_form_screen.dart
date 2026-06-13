import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/models/crop.dart';
import 'package:agro_spray/providers/crop_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CropFormScreen extends StatefulWidget {
  const CropFormScreen({super.key, this.crop});

  final Crop? crop;

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _varietyController = TextEditingController();
  final _fieldAreaController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _plantingDate = DateTime.now();
  String _status = 'Active';

  @override
  void initState() {
    super.initState();
    final crop = widget.crop;
    if (crop != null) {
      _nameController.text = crop.name;
      _varietyController.text = crop.variety;
      _fieldAreaController.text = crop.fieldArea.toString();
      _notesController.text = crop.notes;
      _plantingDate = crop.plantingDate;
      _status = crop.status;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _varietyController.dispose();
    _fieldAreaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<CropProvider>().saveCrop(
          id: widget.crop?.id,
          name: _nameController.text.trim(),
          variety: _varietyController.text.trim(),
          fieldArea: double.tryParse(_fieldAreaController.text.trim()) ?? 0,
          plantingDate: _plantingDate,
          status: _status,
          notes: _notesController.text.trim(),
          createdAt: widget.crop?.createdAt,
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Crop saved successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cropProvider = context.watch<CropProvider>();

    return LoadingOverlay(
      isLoading: cropProvider.status == RequestStatus.loading,
      child: Scaffold(
        appBar: AppBar(title: Text(widget.crop == null ? 'Add Crop' : 'Edit Crop')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: 'Crop name', controller: _nameController, validator: (value) => Validators.requiredField(value, fieldName: 'Crop name'), prefixIcon: Icons.eco_outlined),
                const SizedBox(height: 16),
                AppTextField(label: 'Variety', controller: _varietyController, validator: (value) => Validators.requiredField(value, fieldName: 'Variety'), prefixIcon: Icons.grass_outlined),
                const SizedBox(height: 16),
                AppTextField(label: 'Field area (acres)', controller: _fieldAreaController, validator: (value) => Validators.requiredField(value, fieldName: 'Field area'), keyboardType: TextInputType.number, prefixIcon: Icons.square_foot_outlined),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _status,
                  items: const [
                    DropdownMenuItem(value: 'Active', child: Text('Active')),
                    DropdownMenuItem(value: 'Harvested', child: Text('Harvested')),
                    DropdownMenuItem(value: 'Monitoring', child: Text('Monitoring')),
                  ],
                  onChanged: (value) => setState(() => _status = value ?? 'Active'),
                  decoration: const InputDecoration(labelText: 'Status'),
                ),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Planting date'),
                  subtitle: Text(_plantingDate.toLocal().toString().split(' ').first),
                  trailing: const Icon(Icons.calendar_today_outlined),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _plantingDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate != null) {
                      setState(() => _plantingDate = pickedDate);
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Notes', controller: _notesController, maxLines: 4, prefixIcon: Icons.notes_outlined),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: widget.crop == null ? 'Save crop' : 'Update crop',
                  onPressed: _save,
                  icon: Icons.save_rounded,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
