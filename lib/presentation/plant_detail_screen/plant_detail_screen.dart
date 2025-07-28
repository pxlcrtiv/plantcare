import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bottom_action_bar_widget.dart';
import './widgets/care_schedule_tab_widget.dart';
import './widgets/health_log_tab_widget.dart';
import './widgets/notes_tab_widget.dart';
import './widgets/photos_tab_widget.dart';
import './widgets/plant_hero_image_widget.dart';
import './widgets/plant_info_widget.dart';

class PlantDetailScreen extends StatefulWidget {
  const PlantDetailScreen({Key? key}) : super(key: key);

  @override
  State<PlantDetailScreen> createState() => _PlantDetailScreenState();
}

class _PlantDetailScreenState extends State<PlantDetailScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _careRemindersEnabled = true;

  // Mock plant data
  final Map<String, dynamic> plantData = {
    "id": 1,
    "name": "Monstera Deliciosa",
    "species": "Monstera deliciosa",
    "difficulty": "Medium",
    "imageUrl":
        "https://images.unsplash.com/photo-1545239705-1564e58b9e4a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    "nextWateringDate": DateTime.now().add(Duration(days: 2)),
    "lastWatered": DateTime.now().subtract(Duration(days: 5)),
    "acquired": DateTime.now().subtract(Duration(days: 120)),
  };

  final List<Map<String, dynamic>> careHistory = [
    {
      "date": DateTime.now().subtract(Duration(days: 1)),
      "type": "Watering",
      "notes": "Soil was quite dry, gave thorough watering",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 5)),
      "type": "Fertilizing",
      "notes": "Applied liquid fertilizer diluted to half strength",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 8)),
      "type": "Pruning",
      "notes": "Removed yellowing leaf and cleaned dust from leaves",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 12)),
      "type": "Watering",
      "notes": "Regular watering schedule",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 18)),
      "type": "Repotting",
      "notes": "Moved to larger pot with fresh potting mix",
    },
  ];

  final List<Map<String, dynamic>> healthLogs = [
    {
      "date": DateTime.now().subtract(Duration(days: 2)),
      "type": "Growth",
      "title": "New Leaf Unfurling",
      "description":
          "A beautiful new leaf is starting to unfurl! The fenestrations are already visible and it looks healthy.",
      "hasPhoto": true,
      "photoUrl":
          "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 7)),
      "type": "Care",
      "title": "Weekly Maintenance",
      "description":
          "Cleaned all leaves with damp cloth and checked for pests. Everything looks healthy and vibrant.",
      "hasPhoto": false,
    },
    {
      "date": DateTime.now().subtract(Duration(days: 14)),
      "type": "Issue",
      "title": "Minor Brown Spots",
      "description":
          "Noticed small brown spots on one leaf. Likely from overwatering. Adjusted watering schedule and improved drainage.",
      "hasPhoto": true,
      "photoUrl":
          "https://images.unsplash.com/photo-1463320726281-696a485928c7?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
    {
      "date": DateTime.now().subtract(Duration(days: 30)),
      "type": "Milestone",
      "title": "First Fenestrated Leaf",
      "description":
          "Celebrated the first leaf with natural splits! The plant is maturing beautifully.",
      "hasPhoto": true,
      "photoUrl":
          "https://images.unsplash.com/photo-1586093248292-4e6636b4e3b8?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
    },
  ];

  final List<Map<String, dynamic>> photos = [
    {
      "url":
          "https://images.unsplash.com/photo-1545239705-1564e58b9e4a?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 1)),
      "caption": "New growth looking amazing!",
    },
    {
      "url":
          "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 7)),
      "caption": "Weekly progress shot",
    },
    {
      "url":
          "https://images.unsplash.com/photo-1586093248292-4e6636b4e3b8?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 14)),
      "caption": "First fenestrated leaf!",
    },
    {
      "url":
          "https://images.unsplash.com/photo-1463320726281-696a485928c7?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 21)),
      "caption": "Before repotting",
    },
    {
      "url":
          "https://images.unsplash.com/photo-1558618666-fcd25c85cd64?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 30)),
      "caption": "When I first got it",
    },
    {
      "url":
          "https://images.unsplash.com/photo-1509423350716-97f2360af2e4?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3",
      "date": DateTime.now().subtract(Duration(days: 45)),
      "caption": "Baby plant stage",
    },
  ];

  final List<Map<String, dynamic>> notes = [
    {
      "date": DateTime.now().subtract(Duration(days: 1)),
      "content":
          "The new leaf is unfurling beautifully! I can already see the fenestrations forming. This plant has really taken off since I moved it to the bright corner by the window.",
      "isImportant": true,
    },
    {
      "date": DateTime.now().subtract(Duration(days: 5)),
      "content":
          "Noticed the soil is drying out faster now that it's getting more light. Will need to adjust watering schedule for summer.",
      "isImportant": false,
    },
    {
      "date": DateTime.now().subtract(Duration(days: 12)),
      "content":
          "Applied diluted liquid fertilizer today. The plant has been growing so fast lately, it definitely needs the extra nutrients.",
      "isImportant": false,
    },
    {
      "date": DateTime.now().subtract(Duration(days: 20)),
      "content":
          "Repotted into a larger terracotta pot with better drainage. Added perlite to the potting mix for better aeration. The roots were getting quite bound.",
      "isImportant": true,
    },
    {
      "date": DateTime.now().subtract(Duration(days: 35)),
      "content":
          "First time seeing pest issues - found a few spider mites. Treated with neem oil spray and increased humidity around the plant.",
      "isImportant": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleEditPhoto() {
    // Navigate to photo editing or camera
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit photo functionality')),
    );
  }

  void _handleSharePlant() {
    // Share plant details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Share plant functionality')),
    );
  }

  void _handleNameEdit() {
    // Handle plant name editing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Plant name updated')),
    );
  }

  void _handleWaterNow() {
    // Log watering event
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Plant watered! Next watering scheduled.'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _handleAddPhoto() {
    // Navigate to camera or photo picker
    Navigator.pushNamed(context, '/plant-identification-camera');
  }

  void _handleLogCareEvent() {
    _showCareEventBottomSheet();
  }

  void _handleAddNote(String note) {
    setState(() {
      notes.insert(0, {
        "date": DateTime.now(),
        "content": note,
        "isImportant": false,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Note added successfully')),
    );
  }

  void _showCareEventBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 50.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                'Log Care Event',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              // Care event options
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.w,
                  childAspectRatio: 1.5,
                  children: [
                    _buildCareEventOption(
                      'Watering',
                      'water_drop',
                      Colors.blue,
                      () => _logCareEvent('Watering'),
                    ),
                    _buildCareEventOption(
                      'Fertilizing',
                      'eco',
                      Colors.green,
                      () => _logCareEvent('Fertilizing'),
                    ),
                    _buildCareEventOption(
                      'Pruning',
                      'content_cut',
                      Colors.orange,
                      () => _logCareEvent('Pruning'),
                    ),
                    _buildCareEventOption(
                      'Repotting',
                      'home_work',
                      Colors.brown,
                      () => _logCareEvent('Repotting'),
                    ),
                    _buildCareEventOption(
                      'Pest Treatment',
                      'bug_report',
                      Colors.red,
                      () => _logCareEvent('Pest Treatment'),
                    ),
                    _buildCareEventOption(
                      'Other',
                      'more_horiz',
                      AppTheme.lightTheme.colorScheme.primary,
                      () => _logCareEvent('Other'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCareEventOption(
      String title, String iconName, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: iconName,
              color: color,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              title,
              style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _logCareEvent(String eventType) {
    Navigator.pop(context);
    setState(() {
      careHistory.insert(0, {
        "date": DateTime.now(),
        "type": eventType,
        "notes": "Care event logged via app",
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$eventType event logged successfully'),
        backgroundColor: AppTheme.getSuccessColor(true),
      ),
    );
  }

  void _showReminderSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 35.h,
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 12.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.colorScheme.outline
                        .withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              Text(
                'Care Reminders',
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 2.h),

              // Reminder toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Enable Reminders',
                    style: AppTheme.lightTheme.textTheme.titleMedium,
                  ),
                  Switch(
                    value: _careRemindersEnabled,
                    onChanged: (value) {
                      setState(() {
                        _careRemindersEnabled = value;
                      });
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),

              SizedBox(height: 2.h),

              if (_careRemindersEnabled) ...[
                Text(
                  'Reminder Time',
                  style: AppTheme.lightTheme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'schedule',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text('9:00 AM'),
                  subtitle: Text('Daily reminder time'),
                  trailing: CustomIconWidget(
                    iconName: 'edit',
                    color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  onTap: () {
                    // Show time picker
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Hero image section
          PlantHeroImageWidget(
            imageUrl: plantData['imageUrl'] as String,
            plantName: plantData['name'] as String,
            onEditPhoto: _handleEditPhoto,
            onSharePlant: _handleSharePlant,
          ),

          // Plant info section
          PlantInfoWidget(
            plantName: plantData['name'] as String,
            species: plantData['species'] as String,
            difficulty: plantData['difficulty'] as String,
            onNameEdit: _handleNameEdit,
          ),

          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.2),
                ),
              ),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: [
                Tab(text: 'Schedule'),
                Tab(text: 'Health'),
                Tab(text: 'Photos'),
                Tab(text: 'Notes'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                CareScheduleTabWidget(
                  nextWateringDate: plantData['nextWateringDate'] as DateTime,
                  onWaterNow: _handleWaterNow,
                  careHistory: careHistory,
                ),
                HealthLogTabWidget(
                  healthLogs: healthLogs,
                ),
                PhotosTabWidget(
                  photos: photos,
                  onAddPhoto: _handleAddPhoto,
                ),
                NotesTabWidget(
                  notes: notes,
                  onAddNote: _handleAddNote,
                ),
              ],
            ),
          ),
        ],
      ),

      // Bottom action bar
      bottomNavigationBar: BottomActionBarWidget(
        onWaterPlant: _handleWaterNow,
        onAddPhoto: _handleAddPhoto,
        onLogCareEvent: _handleLogCareEvent,
      ),

      // Floating action button for reminder settings
      floatingActionButton: FloatingActionButton(
        onPressed: _showReminderSettings,
        child: CustomIconWidget(
          iconName: 'notifications',
          color: Colors.black,
          size: 24,
        ),
        backgroundColor: AppTheme.getAccentColor(true),
      ),
    );
  }
}
