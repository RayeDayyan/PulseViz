import 'package:pulse_viz/helpers/EncryptionHelper.dart'; 

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String cnic;
  final String phone;
  final String occupation;
  final String password;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.cnic,
    required this.phone,
    required this.occupation,
    required this.password,
  });

  // Decrypt CNIC and Phone when fetching from Firebase
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      name: json['name'],
      cnic: EncryptionHelper.decryptData(json['cnic']), // Decrypt CNIC
      phone: EncryptionHelper.decryptData(json['phone']), // Decrypt Phone
      occupation: json['occupation'],
      password: json['password'],
    );
  }

  // Encrypt CNIC and Phone before saving to Firebase
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'cnic': EncryptionHelper.encryptData(cnic), // Encrypt CNIC
      'phone': EncryptionHelper.encryptData(phone), // Encrypt Phone
      'occupation': occupation,
      'password': password,
    };
  }
}
