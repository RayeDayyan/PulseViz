import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // await Future.delayed(Duration(seconds: 2)); // Add a delay to showcase splash


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(ProviderScope(child: MyApp(),));
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser;

    return ResponsiveSizer(builder: (context,orientation,deviceType){
      return MaterialApp(
        title: 'PulseViz',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFD61717)),
          useMaterial3: true,
        ),
        home: user!=null?const CameraScreen():const LoginScreen(),
      );
    });
  }
}

