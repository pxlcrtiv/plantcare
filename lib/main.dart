import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/app_export.dart';
import '../services/sync_service.dart';
import '../services/firebase_service.dart';
import '../providers/sync_provider.dart';
import '../widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return CustomErrorWidget(
      errorDetails: details,
    );
  };
  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();
    final syncService = SyncService(firebaseService, FirebaseFirestore.instance);
    
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SyncProvider>(
          create: (_) => SyncProvider(syncService, firebaseService),
        ),
      ],
      child: Sizer(builder: (context, orientation, screenType) {
        return MaterialApp(
          title: 'plantcare',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.0),
              ),
              child: child!,
            );
          },
          // 🚨 END CRITICAL SECTION
          debugShowCheckedModeBanner: false,
          routes: AppRoutes.routes,
          initialRoute: AppRoutes.initial,  // Back to splash screen as initial
        );
      }),
    );
  }
}
}
