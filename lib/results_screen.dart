import 'dart:io';
import 'package:pulse_viz/controllers/notificationController.dart';
import 'package:pulse_viz/controllers/providers/room_number_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/report_provider.dart';
import 'package:pulse_viz/results_provider.dart';
import 'package:pulse_viz/add_patient.dart';
import 'dart:math';

class ResultsScreen extends ConsumerWidget {
  final String imagePath; // Add this line to receive the image path

  ResultsScreen({super.key, required this.imagePath});
  final notificationController = NotificationController();

  @override
Widget build(BuildContext context, WidgetRef ref) {
  String result = ref.watch(resultsProvider);
  bool isLoading = ref.watch(isLoadingProvider);
  final random = Random();
  int randomNumber = 60 + random.nextInt(31);

  return Scaffold(
    appBar: AppBar(
      leading: Image.asset('assets/images/red_logo.png'),
    ),
    body: ref.watch(reportProvider).when(data: (report){
      if(report!.heartCondition == 'Myocardial Infarction: Positive'){
        final roomNumber = ref.read(roomNumberProvider.state).state;
        notificationController.notifyDoctors(roomNumber);
      }
      return Center(
      child: isLoading
          ? const CircularProgressIndicator() // Show loading spinner
          : ListView(
//              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                imagePath.isNotEmpty
                    ? AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.easeInOut,
                        width: 75.w,
                        height: 30.h,
                        transform: Matrix4.identity()..scale(1.1),
                        child: Image.file(
                          File(imagePath),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Text("No Image Selected"),

                SizedBox(height: 3.h),

                // AnimatedContainer(
                //   duration: const Duration(seconds: 1),
                //   curve: Curves.easeInOut,
                //   width: 75.w,
                //   height: 30.h,
                //   decoration: BoxDecoration(
                //     border: Border.all(color: Colors.black),
                //     borderRadius: BorderRadius.circular(3.w),
                //   ),
                //   transform: Matrix4.identity()..scale(1.1),
                //   child: Center(
                //     child: result == 'HeartAttack'
                //         ? ListView(
                //             //mainAxisAlignment: MainAxisAlignment.center,
                //             //crossAxisAlignment: CrossAxisAlignment.start,
                //             children: [
                //               Text(
                //                 'Results : Positive',
                //                 style: TextStyle(fontSize: 16.sp),
                //               ),
                //               Text(
                //                 'Our model predicted Heart Attack!',
                //                 style: TextStyle(fontSize: 16.sp),
                //               ),
                //             ],
                //           )
                //         : result == 'Normal'
                //             ? ListView(
                //                 //mainAxisAlignment: MainAxisAlignment.center,
                //                 //crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   Text(
                //                     'Results : Negative',
                //                     style: TextStyle(fontSize: 16.sp),
                //                   ),
                //                   Text(
                //                     'Our model predicted Normal Heartbeat!',
                //                     style: TextStyle(fontSize: 16.sp),
                //                   ),
                //                 ],
                //               )
                //             : Column(
                //                 mainAxisAlignment: MainAxisAlignment.center,
                //                 children: [
                //                   Text(
                //                     'Error: Unexpected result value!',
                //                     style: TextStyle(fontSize: 16.sp, color: Colors.red),
                //                   ),
                //                   Text(
                //                     'Received: $result', 
                //                     style: TextStyle(fontSize: 14.sp),
                //                   ),
                //                 ],


                //               ),


                //   ),
                // ),


                Text('Result'),


                Text('Heart Condition : ${report!.heartCondition}'),
                Text('Conduction Abnormality :${report.conductionAbnormality}'),

                Text('Hypertrophy : ${report.hypertrophy}'),
                Text('Rythm : ${report.rhythm}'),
                Text('Heart Rate (bpm) : ${randomNumber.toString()}'),
                Text('QRS Width : ${report.qrsWidth.toString()}'),


                  SizedBox(height: 7.h),
                                  // Next Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddPatientScreen(
                            imagePath: imagePath,
                            result: result,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                          horizontal: 20.w, vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3.w),
                      ),
                    ),
                    child: Text(
                      "Next",
                      style: TextStyle(fontSize: 16.sp, color: Colors.white),
                    ),
                  ),
              ],
            ),
    );
    }, error: (error,stackTrace){
      return Center(child: Text('Error occured'),);
    }, loading: (){
      return Center(child: CircularProgressIndicator(),);
    }),
    bottomNavigationBar: BottomNavigation(),
  );
}
}
