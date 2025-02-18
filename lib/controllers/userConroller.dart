import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:http/http.dart' as http;


class UserController {
  final String baseUrl = 'http://10.0.2.2:3000/user';
  final firestore = FirebaseFirestore.instance;
  Future<bool> signUpUser(UserModel user) async{
    try{
      await firestore.collection('users').doc(user.uid).set(user.toJson());
      return true;
    }catch(e){
      print('error occured : $e');
      return false;
    }
  }

}