import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/providers/current_user_details.dart';
import 'package:pulse_viz/controllers/userController.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class EditProfileScreen extends ConsumerStatefulWidget{
  @override
  ConsumerState<EditProfileScreen> createState() => EditProfileScreenState();
}

class EditProfileScreenState extends ConsumerState<EditProfileScreen>{
  final auth = FirebaseAuth.instance;

  final nameController = TextEditingController();
  final cnicController = TextEditingController();
  final phoneController = TextEditingController();

  bool initialize = true;
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: Image.asset('assets/images/red_logo.png'),
      ),
      body: ref.watch(currentUserDetails).when(data: (user){
        if(user==null){
          return TextButton(onPressed: (){
            auth.signOut();
            Navigator.push(context, MaterialPageRoute(builder: (context)=>LoginScreen()));
          }, child: Text("Failed to fetch data, please login again by clicking here"));
        }else {
          if(initialize){
            nameController.text = user.name;
            cnicController.text = user.cnic;
            phoneController.text = user.phone;
          }
          initialize = false;
          return ListView(
            padding: EdgeInsets.all(3.w),
            children: [
              Text('Name',style: TextStyle(fontSize: 18.sp),),
              TextField(
                controller: nameController,
                style: const TextStyle(
                  fontFamily: 'Poppins-Light',
                ),
                decoration: InputDecoration(
                    hintText: 'Name',
                    hintStyle:
                    TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )),
              ),
              SizedBox(height: 1.h,),

              Text('CNIC',style: TextStyle(fontSize: 18.sp),),
              TextField(
                controller: cnicController,
                style: const TextStyle(
                  fontFamily: 'Poppins-Light',
                ),
                decoration: InputDecoration(
                    hintText: 'CNIC',
                    hintStyle:
                    TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    )),
              ),
              SizedBox(height: 1.h,),

              Text('Contact',style: TextStyle(fontSize: 18.sp),),
              TextField(
                controller: phoneController,
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
              ),
              SizedBox(height: 10.h,),

              Container(
                height: 8.h,
                child: ElevatedButton(onPressed: () async{
                  final userController = UserController();

                  bool result = await userController.updateUserDetails(nameController.text.toString(),
                      cnicController.text.toString(), phoneController.text.toString());
                  if(result == true){
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved Successfully'),));
                  }else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed ! Try again'),));
                  }
                  ref.refresh(currentUserDetails);
                  Navigator.pop(context);

                },style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD61717)
                ), child: Text('Save',style: TextStyle(fontSize: 18.sp,color: Colors.white),))
                ,
              )

            ],
          );
        }
      }, error: (error,stackTrace){
        return Center(child: Text('Error occured'),);
      }, loading: (){
        return Center(child: CircularProgressIndicator(),);
      }),
      bottomNavigationBar: BottomNavigation(),
    );



  }

}