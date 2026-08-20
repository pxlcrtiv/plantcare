import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  static const String _dailyCareRemindersKey =
      'notification_daily_care_reminders';
  static const String _wateringDueAlertsKey = 'notification_watering_due_alerts';
  static const String _careTipsKey = 'notification_care_tips';

  bool _dailyCareReminders = true;
  bool _wateringDueAlerts = true;
  bool _careTips = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _dailyCareReminders =
          prefs.getBool(_dailyCareRemindersKey) ?? _dailyCareReminders;
      _wateringDueAlerts =
          prefs.getBool(_wateringDueAlertsKey) ?? _wateringDueAlerts;
      _careTips = prefs.getBool(_careTipsKey) ?? _careTips;
    });
  }

  Future<void> _savePreference(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Notification Settings',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Card(
          child: Column(
            children: [
              SwitchListTile(
                title: Text('Daily care reminders'),
                value: _dailyCareReminders,
                onChanged: (value) {
                  setState(() => _dailyCareReminders = value);
                  _savePreference(_dailyCareRemindersKey, value);
                },
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Watering due alerts'),
                value: _wateringDueAlerts,
                onChanged: (value) {
                  setState(() => _wateringDueAlerts = value);
                  _savePreference(_wateringDueAlertsKey, value);
                },
              ),
              Divider(height: 1),
              SwitchListTile(
                title: Text('Care tips'),
                value: _careTips,
                onChanged: (value) {
                  setState(() => _careTips = value);
                  _savePreference(_careTipsKey, value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}