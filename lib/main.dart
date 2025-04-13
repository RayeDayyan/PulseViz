import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import 'controllers/notificationController.dart';
import 'firebase_options.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:pulse_viz/search_patient.dart';
import 'package:pulse_viz/add_patient.dart';

@pragma('vm:entry-point')
Future<void> backgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  print('🔔 Background Notification: ${message.notification?.title}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    debugPrint("Firebase initialization error: $e");
  }

  FirebaseMessaging.onBackgroundMessage(backgroundMessageHandler);

  // Initialize notification controller
  final notificationController = NotificationController();
  notificationController.requestPermission();
  
  runApp(ProviderScope(child: MyApp()));
}



class MyApp extends StatelessWidget {
  MyApp({super.key});
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return ResponsiveSizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        title: 'PulseViz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD61717)),
          useMaterial3: true,
        ),
        initialRoute: user != null ? '/camera' : '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/camera': (context) => const CameraScreen(),
          '/search_patient': (context) => SearchPatientScreen(),
          '/add_patient': (context) => const AddPatientScreen(
                            imagePath: '',
                            result: '',
          ), 
        },
      );
    });
  }
}
