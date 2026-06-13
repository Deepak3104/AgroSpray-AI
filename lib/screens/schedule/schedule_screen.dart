import 'package:agro_spray/core/routes/app_routes.dart';
import 'package:agro_spray/core/utils/request_state.dart';
import 'package:agro_spray/providers/schedule_provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheduleProvider = context.watch<ScheduleProvider>();
    final schedules = scheduleProvider.schedules;
    final now = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spray Scheduling'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.scheduleForm),
            icon: const Icon(Icons.add_circle_outline),
          ),
        ],
      ),
      body: scheduleProvider.status == RequestStatus.loading && schedules.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: TableCalendar(
                      firstDay: DateTime(now.year - 1),
                      lastDay: DateTime(now.year + 1),
                      focusedDay: now,
                      calendarFormat: CalendarFormat.month,
                      availableGestures: AvailableGestures.horizontalSwipe,
                      eventLoader: (day) {
                        return schedules
                            .where((schedule) =>
                                schedule.scheduledAt.year == day.year &&
                                schedule.scheduledAt.month == day.month &&
                                schedule.scheduledAt.day == day.day)
                            .toList();
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text('Upcoming schedules', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                ...schedules.map(
                  (schedule) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Card(
                      child: ListTile(
                        leading: const Icon(Icons.calendar_month_rounded),
                        title: Text(schedule.title),
                        subtitle: Text('${schedule.scheduledAt.toLocal()} • Reminder ${schedule.reminderMinutesBefore} min before'),
                        trailing: IconButton(
                          onPressed: () => context.read<ScheduleProvider>().deleteSchedule(schedule.id),
                          icon: const Icon(Icons.delete_outline),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
