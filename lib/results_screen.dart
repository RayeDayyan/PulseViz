import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/results_provider.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ResultsScreen extends ConsumerWidget{
  @override
  Widget build(BuildContext context,WidgetRef ref){
    String result = ref.read(resultsProvider.state).state;
    return Scaffold(
        appBar: AppBar(
          leading: Image.asset('assets/images/red_logo.png'),
        ),
        body: Container(
          child: Center(child: Container(
            width: 75.w,
            height: 30.h,
            decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.black,
                ),
              borderRadius: BorderRadius.circular(3.w)
            ),

            child: Center(
              child: result == 'HeartAttack'
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start, // Center horizontally
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
                mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                crossAxisAlignment: CrossAxisAlignment.start, // Center horizontally
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
          ),),

        bottomNavigationBar: BottomNavigation(),
    );
  }
}