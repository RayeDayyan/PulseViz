import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:pulse_viz/results_provider.dart';
import 'package:pulse_viz/results_screen.dart';
import 'package:pulse_viz/settings_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pulse_viz/loading_screen.dart';
import 'dart:io';


class BottomNavigation extends ConsumerWidget {
  final modelController = ModelController();
  final auth = FirebaseAuth.instance;
  final ImagePicker imagePicker = ImagePicker();
  BottomNavigation({super.key});
  String? result;
  String imagePath = '';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(isLoadingProvider);

  
    return Container(
      height: 7.h,
      color: const Color(0xFFD61717),
      child: Row(
        children: [

          SizedBox(width: 13.w),
          // Upload Button on Left
          IconButton(
  onPressed: isLoading
      ? null
      : () async {
          ref.read(isLoadingProvider.state).state = true; // Start Loading
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoadingScreen()),
          );

          result = await modelController.pickAndSendImage(ref, context);

          ref.read(isLoadingProvider.state).state = false; // Stop Loading

          if (result != 'No Image Selected') {
            ref.read(resultsProvider.state).state = result!;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ResultsScreen(imagePath: modelController.imagePath),
              ),
            );


          } else {
            Navigator.pop(context); // Go back if no image is selected
          }
        },
  icon: isLoading
      ? const CircularProgressIndicator(color: Colors.white)
      : Icon(Icons.upload, color: Colors.white, size: 5.h),
),


          // Spacer to push Camera Button to Center
          SizedBox(width: 17.w),

          // Camera Button in the Center
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CameraScreen(),
                ),
              );
            },
            icon: Icon(Icons.camera_alt, color: Colors.white, size: 5.h),
          ),

          // Spacer to balance layout
          SizedBox(width: 17.w),

          // Settings Button on Right
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsScreen()),
              );
            },
            icon: Icon(Icons.settings, color: Colors.white, size: 5.h),
          ),
          //SizedBox(width: 10.w),
        ],
      ),
    );
  }
}
