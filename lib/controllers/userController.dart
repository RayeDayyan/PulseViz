import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:pulse_viz/helpers/EncryptionHelper.dart';

class UserController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Define Firestore here
  final auth = FirebaseAuth.instance;
  
  Future<bool> signUpUser(UserModel user) async {
    try {
      String cnic = user.cnic;

      await firestore.collection('users').doc(user.uid).set(
        user.toJsonSync(cnic: cnic, encryptedPhone: user.phone),
      );

      return true;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }
  
  Future<UserModel?> fetchCurrentUser() async{
    try{

      final currentUserID =  auth.currentUser!.uid;


      final currentUser = await firestore.collection('users').doc(currentUserID).get();
      final user = await UserModel.fromJson(currentUser.data()!);
      user.phone = await EncryptionHelper.decryptData(user.phone);

      print(user.phone);
      return user;

      
      
    }catch(e){
      print('Error occured while fetching current user $e');
      return null;
    }
  }

  Future<void> updateDutyStatus(bool dutyStatus,BuildContext context) async{
    try{

      final currentUserID = auth.currentUser!.uid;


      await firestore.collection('users').doc(currentUserID).update({
        'onDuty':dutyStatus,
      });

      print('after updating');
    }catch(e){
      print('Error occured : $e');
    }
  }

  Future<bool> updateUserDetails(String name,String cnic, String contact) async{
    try{
      final uid = auth.currentUser!.uid;
      String phone = await EncryptionHelper.encryptData(contact);

      await firestore.collection('users').doc(uid).update({
        'cnic' : cnic,
        'name': name,
        'phone' : phone
      });

    return true;
  }catch(e){
      print("error occured :$e");
      return false;
    }
}}
