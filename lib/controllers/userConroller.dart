import 'dart:convert';

import 'package:pulse_viz/models/userModel.dart';
import 'package:http/http.dart' as http;

class UserController {
  final String baseUrl = 'http://10.0.2.2:3000/user';

  Future<bool> signUpUser(UserModel user) async{
    try{
      //sending request to our node server for signup
      final response = await http.post(Uri.parse('$baseUrl/signUpUser'),
      headers: {'Content-type':'application/json'},
        body: jsonEncode(user.toJson())
      );

     //checking the api response to return either true or false
      if(response.statusCode==201){
        return true;
      }
      else{
        return false;
      }
    }catch(e){
      print('error occured : $e');
      return false;
    }
  }

}