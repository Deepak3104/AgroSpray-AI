import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/models/report.dart';
import 'package:agro_spray/services/pdf_service.dart';
import 'package:agro_spray/providers/report_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  Future<void> _exportPdf(BuildContext context, Report report) async {
    final pdfService = PdfService();
    final bytes = await pdfService.buildReportPdf(report);
    await Printing.layoutPdf(onLayout: (_) async => bytes);
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        actions: [
          IconButton(
            onPressed: () => context.read<ReportProvider>().createReport(
                  title: 'Season Summary',
                  summary: 'Crop health, spray status, and activity overview.',
                ),
            icon: const Icon(Icons.add_chart_rounded),
          ),
        ],
      ),
      body: reportProvider.status == RequestStatus.loading && reportProvider.reports.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : reportProvider.reports.isEmpty
              ? const Center(child: Text('No reports generated yet.'))
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: reportProvider.reports.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = reportProvider.reports[index];
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf_rounded),
                        title: Text(report.title),
                        subtitle: Text(report.summary),
                        trailing: IconButton(
                          onPressed: () => _exportPdf(context, report),
                          icon: const Icon(Icons.download_outlined),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
