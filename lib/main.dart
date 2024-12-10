import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
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
          colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFFD61717)),
          useMaterial3: true,
        ),
        home: user!=null?CameraScreen():LoginScreen(),
      );
    });
  }
}

