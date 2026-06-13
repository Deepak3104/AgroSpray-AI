import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/core/utils/validators.dart';
import 'package:agro_spray/providers/recommendation_provider.dart';
import 'package:agro_spray/widgets/app_text_field.dart';
import 'package:agro_spray/widgets/loading_overlay.dart';
import 'package:agro_spray/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _cropTypeController = TextEditingController();
  final _issueController = TextEditingController();

  @override
  void dispose() {
    _cropTypeController.dispose();
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    await context.read<RecommendationProvider>().searchRecommendation(
          cropType: _cropTypeController.text.trim(),
          issue: _issueController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final recommendationProvider = context.watch<RecommendationProvider>();
    final recommendation = recommendationProvider.recommendation;

    return LoadingOverlay(
      isLoading: recommendationProvider.status == RequestStatus.loading,
      child: Scaffold(
        appBar: AppBar(title: const Text('Pesticide Recommendation')),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    label: 'Crop type',
                    controller: _cropTypeController,
                    validator: (value) => Validators.requiredField(value, fieldName: 'Crop type'),
                    prefixIcon: Icons.eco_outlined,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    label: 'Disease or pest issue',
                    controller: _issueController,
                    validator: (value) => Validators.requiredField(value, fieldName: 'Disease or pest issue'),
                    prefixIcon: Icons.bug_report_outlined,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(label: 'Get recommendation', onPressed: _search, icon: Icons.search_rounded),
                ],
              ),
            ),
            if (recommendation != null) ...[
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(recommendation.recommendedPesticide, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Text('Dosage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(recommendation.dosage),
                      const SizedBox(height: 12),
                      Text('Precautions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(recommendation.precautions),
                      const SizedBox(height: 12),
                      Text('Notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      Text(recommendation.notes),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
