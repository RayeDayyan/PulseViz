import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/camera_screen.dart';
import 'package:pulse_viz/signup_screen.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();

  final auth = FirebaseAuth.instance;

  bool visibility = true;
  void setVisibility() {
    setState(() {
      visibility = !visibility;
    });
  }
  void login() async {
    //if the email or password is empty do not try to login
    if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
      try {
        await auth.signInWithEmailAndPassword(
            email: emailController.text.toString(),
            password: passController.text.toString());

        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Center(
                child: Text('Login Successful'),
              ),
            ));
        //change screen after successful login
        Navigator.push(context, MaterialPageRoute(builder: (context)=>CameraScreen()));

      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Center(
                child: Text('Login Failed!'),
              ),
            ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:  Center(
            child: Text('Incomplete credentials'),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 5.w),
      child: ListView(
        children: [
          Container(
            height: 20.h,
            width: 25.h,
            alignment: Alignment.center,
            decoration:const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/red_logo.png',
                    ),
                    fit: BoxFit.contain)),
          ),
          Text('Login',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 22.sp,
              )),
          SizedBox(
            height: 7.h,
          ),
          Text('Email',
              style: TextStyle(
                fontFamily: 'Poppins-Light',
                fontSize: 18.sp,
              )),
          TextField(
            controller: emailController,
            style: const TextStyle(
              fontFamily: 'Poppins-Light',
            ),
            decoration: InputDecoration(
                hintText: 'Email',
                hintStyle:
                    TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
          ),
          SizedBox(
            height: 2.h,
          ),
          Row(
            children: [
              Text('Password',
                  style: TextStyle(
                    fontFamily: 'Poppins-Light',
                    fontSize: 18.sp,
                  )),
              SizedBox(
                width: 55.w,
              ),
              GestureDetector(
                onTap: setVisibility,
                child: Icon(Icons.remove_red_eye),
              )
            ],
          ),
          TextField(
            obscureText: visibility,
            controller: passController,
            style: const TextStyle(
              fontFamily: 'Poppins-Light',
            ),
            decoration: InputDecoration(
                hintText: 'Password',
                hintStyle:
                    TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
          ),

          SizedBox(height: 5.h,),

          Container(
              height: 8.h,
              child: ElevatedButton(
                  onPressed: login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD61717),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontFamily: 'Poppins-Light',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Color(0XFFEDF4F2),
                    ),
                  ))),

          SizedBox(height: 2.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Don\'t have an account?',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 16.sp),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (() => {
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>SignupScreen())),
                    }),
                child: Text(
                  'Crate one now !',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      color: Color(0xFF31473A)),
                ),
              )
            ],
          )
        ],
      ),
    ));
  }
}
