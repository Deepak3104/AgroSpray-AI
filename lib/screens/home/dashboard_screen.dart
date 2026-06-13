import 'package:agro_spray/core/routes/app_routes.dart';
import 'package:agro_spray/providers/auth_provider.dart';
import 'package:agro_spray/providers/dashboard_provider.dart';
import 'package:agro_spray/widgets/app_logo.dart';
import 'package:agro_spray/widgets/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final stats = context.watch<DashboardProvider>().stats;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const AgroSprayLogo(size: 48, showLabel: false),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('AgroSpray', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                    Text(authProvider.user?.name.isNotEmpty == true ? 'Welcome, ${authProvider.user!.name}' : 'Your crop protection dashboard'),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profile),
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Today\'s focus', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Text('Manage crop health, upcoming spray schedules, and reports from one place.'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cropForm),
                        icon: const Icon(Icons.add_rounded),
                        label: const Text('Add Crop'),
                      ),
                      OutlinedButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scheduleForm),
                        icon: const Icon(Icons.event_available_outlined),
                        label: const Text('New Spray'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: stats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.98,
            ),
            itemBuilder: (context, index) {
              final stat = stats[index];
              return StatCard(
                title: stat.title,
                value: stat.value,
                subtitle: stat.subtitle,
                icon: stat.icon,
                color: stat.color,
              );
            },
          ),
          const SizedBox(height: 20),
          Text('Quick actions', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ActionChip(label: 'Crop History', icon: Icons.history_rounded, onTap: () => Navigator.of(context).pushNamed(AppRoutes.cropHistory)),
              _ActionChip(label: 'Pesticide Advice', icon: Icons.local_florist_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.recommendation)),
              _ActionChip(label: 'Spray Calendar', icon: Icons.calendar_today_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.schedule)),
              _ActionChip(label: 'Reports', icon: Icons.picture_as_pdf_outlined, onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({required this.label, required this.icon, required this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
}
