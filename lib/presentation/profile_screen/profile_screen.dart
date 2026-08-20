import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sizer/sizer.dart';
import '../../core/app_export.dart';
import '../../services/firebase_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = _firebaseService.currentUser;
  }

  Future<void> _signOut() async {
    try {
      await _firebaseService.signOut();
      // Navigate back to login screen
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login-screen',
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign out failed. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTheme.lightTheme.appBarTheme.titleTextStyle,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.lightTheme.colorScheme.onSurface,
      ),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          children: [
            // User info card
            Card(
              child: Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  children: [
                    Container(
                      width: 15.w,
                      height: 15.w,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(7.5.w),
                        border: Border.all(
                          color: AppTheme.lightTheme.colorScheme.outline,
                          width: 0.5,
                        ),
                      ),
                      child: Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 7.w,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _currentUser?.displayName ?? 'User',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            _currentUser?.email ?? 'No email',
                            style: AppTheme.lightTheme.textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme.lightTheme.colorScheme
                                  .onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 3.h),

            // Settings options
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'notifications',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    title: Text('Notification Settings'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to notification settings
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'privacy_tip',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    title: Text('Privacy Settings'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to privacy settings
                    },
                  ),
                  Divider(height: 1),
                  ListTile(
                    leading: CustomIconWidget(
                      iconName: 'help',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 6.w,
                    ),
                    title: Text('Help & Support'),
                    trailing: Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to help screen
                    },
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Sign out button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _signOut,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  side: BorderSide(
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'logout',
                      color: AppTheme.lightTheme.colorScheme.error,
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'Sign Out',
                      style: AppTheme.lightTheme.textTheme.titleMedium
                          ?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}