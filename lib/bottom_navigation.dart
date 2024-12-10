import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class BottomNavigation extends StatelessWidget{

  final modelController = ModelController();

  @override
  Widget build(BuildContext context){
    return Container(
      height: 7.h,
      color: Color(0xFFD61717),
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
          ),
          IconButton(onPressed: (){
            modelController.pickAndPredict();
          },
              icon: Icon(Icons.upload,color: Colors.black,size: 5.h,)),
          SizedBox(
            width: 25.w,
          ),
          IconButton(onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen()));
          },
              icon: Icon(Icons.camera_alt,color: Colors.black,size: 5.h,))
        ],
      ),
    );
  }
}