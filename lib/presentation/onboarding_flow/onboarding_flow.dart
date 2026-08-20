import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/navigation_controls_widget.dart';
import './widgets/onboarding_page_widget.dart';
import './widgets/page_indicator_widget.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({Key? key}) : super(key: key);

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Mock data for onboarding screens
  final List<Map<String, dynamic>> _onboardingData = [
    {
      "title": "Never Forget to Water Again",
      "subtitle":
          "Get personalized care schedules for all your plants. Smart reminders help you maintain the perfect watering routine for healthy, thriving houseplants.",
      "image":
          "https://images.unsplash.com/photo-1416879595882-3373a0480b5b?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8aG91c2VwbGFudHN8ZW58MHx8MHx8fDA%3D",
    },
    {
      "title": "Smart Weather-Based Reminders",
      "subtitle":
          "Receive intelligent notifications that adjust based on weather conditions. Your plants get exactly the right amount of water, automatically.",
      "image":
          "https://images.pexels.com/photos/1002703/pexels-photo-1002703.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=2",
    },
    {
      "title": "Track Your Plant's Growth",
      "subtitle":
          "Capture beautiful before and after photos to document your plant's journey. Build a stunning growth gallery and celebrate your green thumb success.",
      "image":
          "https://cdn.pixabay.com/photo/2018/01/14/23/12/nature-3082832_1280.jpg",
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      // Add haptic feedback for iOS-like experience
      HapticFeedback.lightImpact();

      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipOnboarding() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/my-plants-dashboard');
  }

  void _getStarted() {
    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(context, '/plant-identification-camera');
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          // Skip button in top-right corner
          if (_currentPage < _onboardingData.length - 1)
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 2.h,
                right: 6.w,
              ),
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    padding:
                        EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                  ),
                  child: Text(
                    'Skip',
                    style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            )
          else
            SizedBox(height: MediaQuery.of(context).padding.top + 6.h),

          // Main content area with PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _onboardingData.length,
              itemBuilder: (context, index) {
                final data = _onboardingData[index];
                return OnboardingPageWidget(
                  imagePath: data["image"] as String,
                  title: data["title"] as String,
                  subtitle: data["subtitle"] as String,
                  isLastPage: index == _onboardingData.length - 1,
                  onGetStarted:
                      index == _onboardingData.length - 1 ? _getStarted : null,
                );
              },
            ),
          ),

          // Page indicator
          Container(
            padding: EdgeInsets.symmetric(vertical: 2.h),
            child: PageIndicatorWidget(
              currentPage: _currentPage,
              totalPages: _onboardingData.length,
            ),
          ),

          // Navigation controls
          if (_currentPage < _onboardingData.length - 1)
            NavigationControlsWidget(
              currentPage: _currentPage,
              totalPages: _onboardingData.length,
              onNext: _nextPage,
              onSkip: _skipOnboarding,
            )
          else
            SizedBox(height: 4.h),

          // Bottom safe area
          SizedBox(height: MediaQuery.of(context).padding.bottom + 2.h),
        ],
      ),
    );
  }
}
