import 'package:agro_spray/models/dashboard_stat.dart';
import 'package:flutter/material.dart';

class DashboardProvider extends ChangeNotifier {
  final List<DashboardStat> _stats = [
    DashboardStat(title: 'Active Crops', value: '12', subtitle: 'This season', icon: Icons.eco_rounded, color: Colors.green),
    DashboardStat(title: 'Upcoming Sprays', value: '5', subtitle: 'In 7 days', icon: Icons.event_rounded, color: Colors.orange),
    DashboardStat(title: 'Reports', value: '8', subtitle: 'Generated', icon: Icons.picture_as_pdf_rounded, color: Colors.blue),
    DashboardStat(title: 'Alerts', value: '2', subtitle: 'Need attention', icon: Icons.warning_amber_rounded, color: Colors.red),
  ];

  List<DashboardStat> get stats => _stats;
}
