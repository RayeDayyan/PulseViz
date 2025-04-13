import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/notificationController.dart';
import 'package:pulse_viz/controllers/providers/current_user_details.dart';
import 'package:pulse_viz/controllers/providers/room_number_provider.dart';
import 'package:pulse_viz/controllers/userController.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends ConsumerStatefulWidget{
  @override
  ConsumerState<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends ConsumerState<SettingsScreen>{

  final roomNumberController = TextEditingController();
  final auth = FirebaseAuth.instance;
  bool onDuty = false;
  final userController = UserController();




  @override
  Widget build(BuildContext context){
    final roomNumber = ref.read(roomNumberProvider.state).state;
    roomNumberController.text = roomNumber.toString();

    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/red_logo.png'),
      ),
      body: ref.watch(currentUserDetails).when(data: (user){
        return user!.occupation == 'Nurse' ? ListView(
          padding: EdgeInsets.all(3.w),
          children: [
            SizedBox(height: 15.h),
            Row(
              children: [
                Text('Room Number : ',style: TextStyle(fontSize: 18.sp),),
                Expanded(child: TextField(
                  controller: roomNumberController,
                  style: TextStyle(fontSize: 18.sp),
                )),
              ],
            ),

            SizedBox(height : 5.h),

            ElevatedButton(
                onPressed: (){
                  ref.read(roomNumberProvider.state).state = int.parse(roomNumberController.text.toString());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red
                ),
                child: Text('Save',style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white
                ),)),

              SizedBox(height: 30.h,),

              ElevatedButton(onPressed: (){
                auth.signOut();
                Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
              },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD61717)
                ),
                child:  Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.logout,color: Colors.white,size: 3.h,),
                        SizedBox(width:2.w,),
                        Text('Sign out',style: TextStyle(fontSize: 18.sp,color: Colors.white),)
                      ],
                    ),
                  )
          ],
        ) : ListView(
          padding: EdgeInsets.all(3.w),
          children: [
            SizedBox(height: 15.h),
            Text('On Duty', style: TextStyle(fontSize: 18.sp,fontFamily: 'Poppins'),),
            SizedBox(height: 1.h,),

            Container(
              height: 6.5.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30), // Rounded corners
                color: const Color(0xFF575252), // Background color
              ),
              child: Row(
                children: [
                  // Doctor Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          onDuty = true;
                          userController.updateDutyStatus(onDuty);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: onDuty ? const Color(0xFFD61717) : Colors.transparent,
                          borderRadius: BorderRadius.circular(5.w),
                        ),
                        child: Text(
                          'Yes',
                          style: TextStyle(
                              color: Colors.white ,
                              fontSize: 18.sp,
                              fontFamily: 'Poppins'
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Nurse Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          onDuty = false;
                          userController.updateDutyStatus(onDuty);
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: !onDuty ? const Color(0xFFD61717) : Colors.transparent,
                          borderRadius: BorderRadius.circular(5.w),),
                        child: Text(
                          'No',
                          style: TextStyle(
                              color: Colors.white ,
                              fontSize: 18.sp,
                              fontFamily: 'Poppins'
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 30.h,),

            ElevatedButton(onPressed: (){
              auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
            },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD61717)
              ),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout,color: Colors.white,size: 3.h,),
                  SizedBox(width:2.w,),
                  Text('Sign out',style: TextStyle(fontSize: 18.sp,color: Colors.white),)
                ],
              ),
            )
          ],
        );
      }, error: (error,stackTrace){
        return Text('Error occured while fetching user data,please try again');
      }, loading: (){
        return Center(child: CircularProgressIndicator(),);
      }),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}