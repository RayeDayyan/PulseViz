import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/notificationController.dart';
import 'package:pulse_viz/controllers/providers/current_user_details.dart';
import 'package:pulse_viz/controllers/providers/room_number_provider.dart';
import 'package:pulse_viz/controllers/userController.dart';
import 'package:pulse_viz/edit_profile_screen.dart';
import 'package:pulse_viz/helpers/EncryptionHelper.dart';
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
        actions: [
          IconButton(onPressed: (){
            auth.signOut();
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> LoginScreen()));
          }, icon: Icon(Icons.logout,size: 4.h,color: Colors.black,))
        ],
      ),
      body: ref.watch(currentUserDetails).when(data: (user){
        if(user==null){
          return TextButton(
              onPressed: (){
                auth.signOut();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
                ref.refresh(currentUserDetails);


              },
              child: Text(
              'Please login again',));

        }

        print(user.email);
        print(user.occupation);
        return user!.occupation == 'Nurse' ? ListView(
          padding: EdgeInsets.all(3.w),
          children: [
            Row(
              children: [
                Text('Room Number : ',style: TextStyle(fontSize: 18.sp),),
                Expanded(child: TextField(
                  controller: roomNumberController,
                  style: const TextStyle(
                    fontFamily: 'Poppins-Light',
                  ),
                  decoration: InputDecoration(
                      hintText: 'Contact',
                      hintStyle:
                      TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      )),
                ),),
              ],
            ),

            SizedBox(height : 5.h),

            ElevatedButton(
                onPressed: (){
                  ref.read(roomNumberProvider.state).state = int.parse(roomNumberController.text.toString());
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD61717)
                ),
                child: Text('Save',style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.white
                ),)),

              SizedBox(height: 3.h),
                  Text('Name : ${user.name}',style: TextStyle(
                    fontSize: 18.sp,

                  ),),
                  Text('CNIC : ${user.cnic}',style: TextStyle(
                    fontSize: 18.sp,

                  ),),

                  Text('Email : ${user.email}',style: TextStyle(
                    fontSize: 18.sp,

                  ),),

            Text('Occupation : ${user.occupation}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            Text('Contact : ${user.phone}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            SizedBox(height: 30.h,),
            
            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfileScreen()));
            },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD61717)
                ),
                child: Text('Edit Profile',style: TextStyle(fontSize: 18.sp,color: Colors.white),)),

          ],
        ) : ListView(
          padding: EdgeInsets.all(3.w),
          children: [
            SizedBox(height: 7.h),
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
                          userController.updateDutyStatus(onDuty,context);
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
                          userController.updateDutyStatus(onDuty,context);
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

            SizedBox(height: 3.h),
            Text('Name : ${user.name}',style: TextStyle(
              fontSize: 18.sp,

            ),),
            Text('CNIC : ${user.cnic}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            Text('Email : ${user.email}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            Text('Occupation : ${user.occupation}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            Text('Contact : ${user.phone}',style: TextStyle(
              fontSize: 18.sp,

            ),),

            SizedBox(height: 30.h,),

            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=> EditProfileScreen()));
            },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD61717)
                ),
                child: Text('Edit Profile',style: TextStyle(fontSize: 18.sp,color: Colors.white),)),



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