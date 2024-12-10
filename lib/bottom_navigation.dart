import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:pulse_viz/results_provider.dart';
import 'package:pulse_viz/results_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BottomNavigation extends ConsumerWidget{

  final modelController = ModelController();
  final auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context,WidgetRef ref){
    return Container(
      height: 7.h,
      color: Color(0xFFD61717),
      child: Row(
        children: [
          SizedBox(
            width: 15.w,
          ),
          IconButton(onPressed: ()async {
            String result = await modelController.pickAndSendImage();
            if(result != 'No Image Selected'){
              ref.read(resultsProvider.state).state = result;
              Navigator.push(context, MaterialPageRoute(builder: (context)=>ResultsScreen()));
            }

          },
              icon: Icon(Icons.upload,color: Colors.white,size: 5.h,)),
          SizedBox(
            width: 17.w,
          ),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen()));
          },
              icon: Icon(Icons.camera_alt,color: Colors.white,size: 5.h,)),
          SizedBox(
            width: 17.w,
          ),
          IconButton(onPressed: (){
              auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));

          },
              icon: Icon(Icons.settings,color: Colors.white,size: 5.h,))
        ],
      ),
    );
  }
}