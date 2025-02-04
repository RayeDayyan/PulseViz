import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/controllers/userConroller.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class SignupScreen extends StatefulWidget{
  @override
  State<SignupScreen> createState() => SignupScreenState();
}

class SignupScreenState extends State<SignupScreen>{
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController cnicController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController confirmController = TextEditingController();
  final userController = UserController();
  bool isDoctor = true;
  final auth = FirebaseAuth.instance;

  bool visibility = true;
  void setVisibility() {
    setState(() {
      visibility = !visibility;
    });
  }

  void signUp() async {
    //signing up the user when the email and pass are not empty,first authenticated through firebase and then on our backend database
    if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {
      await auth.createUserWithEmailAndPassword(
          email: emailController.text.toString(),
          password: passController.text.toString());

      String uid = auth.currentUser!.uid;

      String role = 'Doctor';
      if(isDoctor==false){
        role='Nurse';
      }

      final user = UserModel(
          uid: uid,
          email:emailController.text.toString(),
          name: nameController.text.toString(),
          cnic: cnicController.text.toString(),
          phone: phoneController.text.toString(),
          occupation: role,
          password: passController.text.toString());

      final result= await userController.signUpUser(user);

      if(result==true){
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Center(
                child: Text('Signup Successful'),
              ),
            ));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => LoginScreen()));

      }else{
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:  Center(
                child: Text('Signup failed'),
              ),
            ));

      }

    }
    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Incomplete Credentials')));
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 2.h,horizontal: 5.w),
        children: [
          Container(
            height: 25.h,
            width: 25.h,
            alignment: Alignment.center,
            decoration:const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(
                      'assets/images/red_logo.png',
                    ),
                    fit: BoxFit.contain)),
          ),

          SizedBox(height: 1.h,),

          Text(
            'Signup',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 22.sp,
            ),
          ),

          SizedBox(height: 1.h,),

          Text(
            'Email',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),
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

          SizedBox(height: 0.5.h,),

          Text(
            'Full Name',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),
          TextField(
            controller: nameController,
            style: const TextStyle(
              fontFamily: 'Poppins-Light',
            ),
            decoration: InputDecoration(
                hintText: 'Full Name',
                hintStyle:
                TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
          ),

          SizedBox(height: 0.5.h,),

          Text(
            'CNIC',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),
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

          SizedBox(height: 0.5.h,),


          Text(
            'Phone Number',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),
          TextField(
            controller: phoneController,
            style: const TextStyle(
              fontFamily: 'Poppins-Light',
            ),
            decoration: InputDecoration(
                hintText: 'Phone Number',
                hintStyle:
                TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
          ),

          Text(
            'Occupation',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),

          SizedBox(height: 1.h,),

      Container(
        height: 6.5.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30), // Rounded corners
          color: Color(0xFF575252), // Background color
        ),
        child: Row(
          children: [
            // Doctor Button
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    isDoctor = true;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDoctor ? Color(0xFFD61717) : Colors.transparent,
                    borderRadius: BorderRadius.circular(5.w),
                  ),
                  child: Text(
                    'Doctor',
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
                    isDoctor = false;
                  });
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: !isDoctor ? Color(0xFFD61717) : Colors.transparent,
                    borderRadius: BorderRadius.circular(5.w),),
                  child: Text(
                    'Nurse',
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

          SizedBox(height: 0.5.h,),
          Row(
            children: [
              Text(
                'Password',
                style: TextStyle(
                  fontFamily: 'Poppins-Light',
                  fontSize: 18.sp,
                ),
              ),
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
          SizedBox(
            height: 1.h,
          ),
          Text(
            '*Password must be atleast 6 characters long',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 14.sp,
            ),
          ),

          SizedBox(height: 0.5.h,),
          Text(
            'Confirm Password',
            style: TextStyle(
              fontFamily: 'Poppins-Light',
              fontSize: 18.sp,
            ),
          ),
          TextField(
            obscureText: visibility,
            controller: confirmController,
            style: const TextStyle(
              fontFamily: 'Poppins-Light',
            ),
            decoration: InputDecoration(
                hintText: 'Confirm Password',
                hintStyle:
                TextStyle(fontFamily: 'Poppins-Light', fontSize: 14.sp),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                )),
          ),

          SizedBox(
            height: 5.h,
          ),
          Container(
              height: 8.h,
              child: ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color((0xFFD61717)),
                  ),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      fontFamily: 'Poppins-Light',
                      fontSize: 18.sp,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: Color(0XFFEDF4F2),
                    ),
                  ))),

          SizedBox(height: 1.h,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account?',
                style: TextStyle(fontFamily: 'Poppins', fontSize: 14.sp),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: (() => {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginScreen()))
                }),
                child: Text(
                  'Login Now !',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: Color(0xFF31473A)),
                ),
              )
            ],
          ),
          SizedBox(
            height: 5.h,
          ),

        ],
      ),
    );
  }
}