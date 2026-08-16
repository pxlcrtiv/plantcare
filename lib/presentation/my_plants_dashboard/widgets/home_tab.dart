import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../models/plant.dart';
import '../../../widgets/metric_icons.dart';
import '../../../widgets/pill_tabs.dart';
import '../../../widgets/section_header.dart';
import '../../add_plant_screen/widgets/plant_database_browser.dart';

/// Home tab of the reference design: greeting header with decorative
/// curved stroke, QR + menu icons, environment pills, "My Plants"
/// horizontal cards and "Popular plants" list.
class HomeTab extends StatefulWidget {
  final String userName;
  final String locationLabel;
  final List<Plant> plants;
  final int environmentIndex;
  final ValueChanged<int> onEnvironmentChanged;
  final void Function(Plant) onPlantTap;
  final VoidCallback onAddPlant;
  final void Function(Map<String, dynamic> databasePlant) onAddFromDatabase;
  final VoidCallback onViewAllPlants;
  final VoidCallback onViewAllPopular;
  final VoidCallback onProfile;
  final VoidCallback onCalendar;
  final VoidCallback onScan;

  const HomeTab({
    super.key,
    required this.userName,
    required this.locationLabel,
    required this.plants,
    required this.environmentIndex,
    required this.onEnvironmentChanged,
    required this.onPlantTap,
    required this.onAddPlant,
    required this.onAddFromDatabase,
    required this.onViewAllPlants,
    required this.onViewAllPopular,
    required this.onProfile,
    required this.onCalendar,
    required this.onScan,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  static const _environments = ['Indoor', 'Outdoor', 'Both'];

  List<Plant> get _visiblePlants {
    final env = _environments[widget.environmentIndex];
    if (env == 'Both') return widget.plants;
    return widget.plants.where((p) {
      final loc = (p.location ?? '').toLowerCase();
      // Unlocated plants show under every environment until assigned.
      if (loc.isEmpty) return true;
      return env == 'Indoor'
          ? loc.contains('indoor')
          : loc.contains('outdoor');
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final plants = _visiblePlants;

    return Stack(
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(painter: _CurvePainter(color: colorScheme.primary)),
          ),
        ),
        ListView(
          padding: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 3.h),
          children: [
            _buildHeader(context, colorScheme),
            SizedBox(height: 2.5.h),
            PillTabRow(
              options: _environments,
              selectedIndex: widget.environmentIndex,
              onSelected: widget.onEnvironmentChanged,
            ),
            SizedBox(height: 3.h),
            SectionHeader(title: 'My Plants', onViewAll: widget.onViewAllPlants),
            SizedBox(height: 1.5.h),
            if (plants.isEmpty)
              _buildEmptyPlants(context, colorScheme)
            else
              SizedBox(
                height: 26.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: plants.length,
                  separatorBuilder: (_, __) => SizedBox(width: 3.w),
                  itemBuilder: (context, index) {
                    final plant = plants[index];
                    return _PlantCard(
                      plant: plant,
                      isDark: isDark,
                      width: 45.w,
                      onTap: () => widget.onPlantTap(plant),
                    );
                  },
                ),
              ),
            SizedBox(height: 3.h),
            SectionHeader(
                title: 'Popular plants', onViewAll: widget.onViewAllPopular),
            SizedBox(height: 1.5.h),
            for (final plant in PlantDatabaseBrowser.plantDatabase.take(5))
              _PopularPlantRow(
                plant: plant,
                isDark: isDark,
                onAdd: () => widget.onAddFromDatabase(plant),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? Colors.white70 : const Color(0xFF2D2D2D);
    final iconBg = isDark ? Theme.of(context).cardColor : Colors.white;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi ${widget.userName} !',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
              ),
              SizedBox(height: 0.8.h),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: 14, color: colorScheme.primary),
                  SizedBox(width: 0.5.w),
                  Text(
                    widget.locationLabel,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white70 : const Color(0xFF888888),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: widget.onScan,
            padding: EdgeInsets.zero,
            icon: Icon(Icons.qr_code, size: 20, color: iconColor),
          ),
        ),
        SizedBox(width: 2.w),
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: PopupMenuButton<String>(
            icon: Icon(Icons.menu, size: 20, color: iconColor),
            padding: EdgeInsets.zero,
            offset: const Offset(0, 44),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: Theme.of(context).cardColor,
            onSelected: (value) {
              if (value == 'profile') widget.onProfile();
              if (value == 'calendar') widget.onCalendar();
              if (value == 'add') widget.onAddPlant();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'add', child: Text('Add a plant')),
              PopupMenuItem(value: 'calendar', child: Text('Calendar')),
              PopupMenuItem(value: 'profile', child: Text('Profile')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlants(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(Icons.local_florist, size: 34, color: colorScheme.primary),
          SizedBox(height: 1.h),
          Text(
            'No plants here yet',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          SizedBox(height: 0.5.h),
          Text(
            'Add your first plant to start caring for it.',
            style: TextStyle(
                fontSize: 12, color: const Color(0xFF888888)),
          ),
          SizedBox(height: 1.5.h),
          ElevatedButton(
            onPressed: widget.onAddPlant,
            child: const Text('Add your first plant'),
          ),
        ],
      ),
    );
  }
}

class _PlantCard extends StatelessWidget {
  final Plant plant;
  final bool isDark;
  final double width;
  final VoidCallback onTap;

  const _PlantCard({
    required this.plant,
    required this.isDark,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final humidity = plant.humidity ?? 65;
    final light = plant.light ?? 'Sunny';
    final moisture =
        (plant.status == 'healthy') ? 100 : 40;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
              child: Image.network(
                plant.imageUrl,
                height: 11.h,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 11.h,
                  color: const Color(0xFFEDEDE4),
                  child: Icon(Icons.local_florist,
                      size: 32, color: const Color(0xFF888888)),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(2.5.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plant.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.3.h),
                  Text(
                    plant.species.isEmpty ? 'Plant' : plant.species,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFF888888)),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.2.w,
                    runSpacing: 0.6.h,
                    children: [
                      MetricIcon.thermometer(context, '$humidity%'),
                      MetricIcon.sun(context, light),
                      MetricIcon.droplet(context, '$moisture'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopularPlantRow extends StatelessWidget {
  final Map<String, dynamic> plant;
  final bool isDark;
  final VoidCallback onAdd;

  const _PopularPlantRow({
    required this.plant,
    required this.isDark,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              plant['image'] as String,
              width: 14.w,
              height: 14.w,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 14.w,
                height: 14.w,
                color: const Color(0xFFEDEDE4),
                child: Icon(Icons.local_florist,
                    size: 22, color: const Color(0xFF888888)),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant['commonName'] as String,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 0.3.h),
                Text(
                  '${plant['name']} · ${plant['lightRequirement']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: Color(0xFF888888)),
                ),
              ],
            ),
          ),
          SizedBox(width: 2.w),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add, size: 20, color: colorScheme.onPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Decorative soft curve behind the header (reference design).
class _CurvePainter extends CustomPainter {
  final Color color;

  _CurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(-size.width * 0.05, size.height * 0.62)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.30,
        size.width * 0.72,
        size.height * 0.92,
        size.width * 1.05,
        size.height * 0.45,
      );
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CurvePainter oldDelegate) =>
      oldDelegate.color != color;
}