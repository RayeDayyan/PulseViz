import 'dart:convert';

import 'package:pulse_viz/models/userModel.dart';
import 'package:http/http.dart' as http;

class UserController {
  final String baseUrl = 'http://10.0.2.2:3000/user';

  Future<bool> signUpUser(UserModel user) async{
    try{
      print('before signup');
      print(user.toJson());
      final response = await http.post(Uri.parse('$baseUrl/signUpUser'),
      headers: {'Content-type':'application/json'},
        body: jsonEncode(user.toJson())
      );

      print('after signup');

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