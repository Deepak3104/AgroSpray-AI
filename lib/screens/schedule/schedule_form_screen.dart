import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/providers/schedule_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleFormScreen extends StatefulWidget {
  const ScheduleFormScreen({super.key});

  @override
  State<ScheduleFormScreen> createState() => _ScheduleFormScreenState();
}

class _ScheduleFormScreenState extends State<ScheduleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropIdController = TextEditingController();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _reminderController = TextEditingController(text: '30');
  DateTime _scheduledAt = DateTime.now().add(const Duration(days: 1));

  @override
  void dispose() {
    _cropIdController.dispose();
    _titleController.dispose();
    _notesController.dispose();
    _reminderController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<ScheduleProvider>().saveSchedule(
          cropId: _cropIdController.text.trim(),
          title: _titleController.text.trim(),
          scheduledAt: _scheduledAt,
          reminderMinutesBefore: int.tryParse(_reminderController.text.trim()) ?? 30,
          status: 'Scheduled',
          notes: _notesController.text.trim(),
        );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Schedule saved successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();

    return LoadingOverlay(
      isLoading: scheduleProvider.status == RequestStatus.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Spray Schedule')),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(label: 'Crop ID', controller: _cropIdController, validator: (value) => Validators.requiredField(value, fieldName: 'Crop ID'), prefixIcon: Icons.tag_outlined),
                const SizedBox(height: 16),
                AppTextField(label: 'Schedule title', controller: _titleController, validator: (value) => Validators.requiredField(value, fieldName: 'Schedule title'), prefixIcon: Icons.title_outlined),
                const SizedBox(height: 16),
                AppTextField(label: 'Reminder minutes before', controller: _reminderController, validator: (value) => Validators.requiredField(value, fieldName: 'Reminder minutes'), keyboardType: TextInputType.number, prefixIcon: Icons.notifications_active_outlined),
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled date/time'),
                  subtitle: Text(_scheduledAt.toLocal().toString()),
                  trailing: const Icon(Icons.date_range_outlined),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _scheduledAt,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (pickedDate == null) {
                      return;
                    }
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_scheduledAt),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        _scheduledAt = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(label: 'Notes', controller: _notesController, maxLines: 3, prefixIcon: Icons.notes_outlined),
                const SizedBox(height: 24),
                PrimaryButton(label: 'Save schedule', onPressed: _save, icon: Icons.event_available_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
