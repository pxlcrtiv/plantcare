import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class BottomNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavigationWidget({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      backgroundColor:
          Theme.of(context).bottomNavigationBarTheme.backgroundColor,
      selectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
      unselectedItemColor:
          Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
      selectedLabelStyle:
          Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
      unselectedLabelStyle:
          Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle,
      elevation: 8,
      items: [
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: CustomIconWidget(
              iconName: 'local_florist',
              color: currentIndex == 0
                  ? Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor!
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor!,
              size: 6.w,
            ),
          ),
          label: 'My Plants',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: CustomIconWidget(
              iconName: 'calendar_today',
              color: currentIndex == 1
                  ? Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor!
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor!,
              size: 6.w,
            ),
          ),
          label: 'Calendar',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: CustomIconWidget(
              iconName: 'camera_alt',
              color: currentIndex == 2
                  ? Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor!
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor!,
              size: 6.w,
            ),
          ),
          label: 'Camera',
        ),
        BottomNavigationBarItem(
          icon: Padding(
            padding: EdgeInsets.only(bottom: 1.h),
            child: CustomIconWidget(
              iconName: 'person',
              color: currentIndex == 3
                  ? Theme.of(context)
                      .bottomNavigationBarTheme
                      .selectedItemColor!
                  : Theme.of(context)
                      .bottomNavigationBarTheme
                      .unselectedItemColor!,
              size: 6.w,
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
