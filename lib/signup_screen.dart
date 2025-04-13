import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/controllers/userController.dart';
import 'package:pulse_viz/login_screen.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:pulse_viz/helpers/EncryptionHelper.dart';

class SignupScreen extends StatefulWidget{
  const SignupScreen({super.key});

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

  String hashPassword(String Password)
  {
    var bytes = utf8.encode(Password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  bool visibility = true;
  void setVisibility() {
    setState(() {
      visibility = !visibility;
    });
  }

  void showError(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
  );
}

void showSuccess(String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message, style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
  );
}

void signUp() async {
  String email = emailController.text.trim();
  String password = passController.text.trim();
  String confirmPassword = confirmController.text.trim();
  String cnic = cnicController.text.trim();
  String phone = phoneController.text.trim();
  String name = nameController.text.trim();

  if(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || cnic.isEmpty || phone.isEmpty || name.isEmpty) {
    showError('Please fill in the required fields.');
    return;  
  }

  if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email)) {
    showError('Invalid email format');
    return;
  }

  if(!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{6,}$').hasMatch(password)) {
    showError('Password must be at least 6 characters and include uppercase, lowercase, number, and a special character.');
    return;
  }

  if(password != confirmPassword) {
    showError('Passwords do not match.');
    return;
  }

  if(!RegExp(r'^\d{13}$').hasMatch(cnic)) {
    showError('Invalid CNIC. It must be 13 digits.');
    return;
  }

  if(!RegExp(r'^03\d{9}$').hasMatch(phone)) {
    showError('Invalid phone number. It must start with 03 and be 11 digits.');
    return;
  }

  try {
    await auth.createUserWithEmailAndPassword(email: email, password: password);
    String uid = auth.currentUser!.uid;

    String role = isDoctor ? 'Doctor' : 'Nurse';
    String hashedPassword = hashPassword(password);

    // Await encryption before passing it to UserModel
    String encryptedPhone = await EncryptionHelper.encryptData(phone);

    final user = UserModel(
      uid: uid,
      email: email,
      name: name,
      cnic: cnic, 
      phone: encryptedPhone, // Encrypted Phone
      occupation: role,
      password: hashedPassword,
      onDuty: false
    );

    final result = await userController.signUpUser(user);

    if (result == true) {
      showSuccess('Signup Successful');
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
    } else {
      showError('Signup failed');
    }
  } catch (e) {
    showError('Error: ${e.toString()}');
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
          color: const Color(0xFF575252), // Background color
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
                    color: isDoctor ? const Color(0xFFD61717) : Colors.transparent,
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
                    color: !isDoctor ? const Color(0xFFD61717) : Colors.transparent,
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
                child: const Icon(Icons.remove_red_eye),
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
          SizedBox(
              height: 8.h,
              child: ElevatedButton(
                  onPressed: signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color((0xFFD61717)),
                  ),
                  child: Text(
                    'Signup',
                    style: TextStyle(
                      fontFamily: 'Poppins-Light',
                      fontSize: 18.sp,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                      color: const Color(0XFFEDF4F2),
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
                      MaterialPageRoute(builder: (context) => const LoginScreen()))
                }),
                child: Text(
                  'Login Now !',
                  style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14.sp,
                      color: const Color(0xFF31473A)),
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