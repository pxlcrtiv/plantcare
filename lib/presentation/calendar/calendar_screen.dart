import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../models/plant.dart';

class CalendarScreen extends StatelessWidget {
  final List<Plant> plants;

  const CalendarScreen({super.key, required this.plants});

  @override
  Widget build(BuildContext context) {
    final events = _buildEvents();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.1),
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'arrow_back',
                        color: Theme.of(context).colorScheme.onSurface,
                        size: 6.w,
                      ),
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Text(
                    'Calendar',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Expanded(
              child: events.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(horizontal: 5.w),
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        return _EventCard(event: event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  List<_WateringEvent> _buildEvents() {
    final events = <_WateringEvent>[];
    for (final plant in plants) {
      final next = plant.nextWatering;
      if (next == null || next.isEmpty) continue;
      final parsed = DateTime.tryParse(next);
      if (parsed == null) continue;
      events.add(_WateringEvent(plant: plant, date: parsed));
    }
    events.sort((a, b) => a.date.compareTo(b.date));
    return events;
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'event',
            color: Theme.of(context).colorScheme.primary,
            size: 12.w,
          ),
          SizedBox(height: 2.h),
          Text(
            'No upcoming watering events',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Add a plant or water one to see its schedule here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }
}

class _WateringEvent {
  final Plant plant;
  final DateTime date;

  const _WateringEvent({required this.plant, required this.date});
}

class _EventCard extends StatelessWidget {
  final _WateringEvent event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(event.date.year, event.date.month, event.date.day);
    final daysLeft = due.difference(today).inDays;

    final bool overdue = daysLeft < 0;
    final String label = overdue
        ? '${-daysLeft} day${daysLeft == -1 ? '' : 's'} overdue'
        : daysLeft == 0
            ? 'Due today'
            : 'In $daysLeft day${daysLeft == 1 ? '' : 's'}';

    final String dateLabel = [
      '${event.date.day}',
      '${event.date.month}',
      '${event.date.year}',
    ].join('/');

    final accent = overdue
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.08,
              ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  '${event.date.day}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accent,
                      ),
                ),
                Text(
                  _monthAbbrev(event.date.month),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: accent,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.plant.name,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  String _monthAbbrev(int month) {
    const months = [
      'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
      'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
    ];
    return months[month - 1];
  }
}