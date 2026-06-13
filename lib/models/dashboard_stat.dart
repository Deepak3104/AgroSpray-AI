import 'package:flutter/material.dart';

class DashboardStat {
  DashboardStat({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.subtitle,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
}
