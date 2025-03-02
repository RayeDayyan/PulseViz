import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/results_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ResultsScreen extends ConsumerWidget {
  final String imagePath; // Add this line to receive the image path

  const ResultsScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String result = ref.read(resultsProvider.state).state;

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/red_logo.png'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            imagePath.isNotEmpty
                ? AnimatedContainer(
                    duration: const Duration(seconds: 1),
                    curve: Curves.easeInOut,
                    width: 75.w,
                    height: 30.h,
                    child: Image.file(
                      File(imagePath),
                      fit: BoxFit.cover,
                    ),
                    transform: Matrix4.identity()..scale(1.1),
                    onEnd: () {
                      // Add bounce effect
                    },
                  )
                : const Text("No Image Selected"),

            const SizedBox(height: 20),

            AnimatedContainer(
              duration: const Duration(seconds: 1),
              curve: Curves.easeInOut,
              width: 75.w,
              height: 30.h,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(3.w),
              ),
              transform: Matrix4.identity()..scale(1.1),
              onEnd: () {
                // Add bounce effect
              },
              child: Center(
                child: result == 'HeartAttack'
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Results : Positive',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                          Text(
                            'Our model predicted Heart Attack!',
                            style: TextStyle(fontSize: 16.sp),
                          ),
                        ],
                      )
                    : result == 'Normal'
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Results : Negative',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                              Text(
                                'Our model predicted Normal Heartbeat!',
                                style: TextStyle(fontSize: 16.sp),
                              ),
                            ],
                          )
                        : Text(
                            'Error occurred',
                            style: TextStyle(fontSize: 16.sp),
                          ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
