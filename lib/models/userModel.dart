import 'package:pulse_viz/helpers/EncryptionHelper.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String cnic;
  final String phone;
  final String occupation;
  final String password;
  final bool onDuty;
  String? fcmToken;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.cnic,
    required this.phone,
    required this.occupation,
    required this.password,
    required this.onDuty,
    this.fcmToken
  });

  // Convert JSON to UserModel (Decrypt Phone)
  static Future<UserModel> fromJson(Map<String, dynamic> json) async {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      cnic: json['cnic'],
      phone: await EncryptionHelper.decryptData(json['phone']),
      occupation: json['occupation'],
      password: json['password'],
      onDuty : json['onDuty'] ?? false,
      fcmToken: json['fcmToken']

    );
  }

  // Convert UserModel to JSON (Pre-encrypt CNIC & Phone)
  Future<Map<String, dynamic>> toEncryptedJson() async {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'cnic': cnic, 
      'phone': await EncryptionHelper.encryptData(phone),
      'occupation': occupation,
      'password': password,
      'onDuty': onDuty
    };
  }

  // **New method: Synchronous version of toJson()**
  Map<String, dynamic> toJsonSync({required String cnic, required String encryptedPhone}) {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'cnic': cnic, 
      'phone': encryptedPhone,
      'occupation': occupation,
      'password': password,
      'onDuty':onDuty,
    };
  }
}
