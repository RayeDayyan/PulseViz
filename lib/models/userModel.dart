class UserModel {
  final String uid;
  final String email;
  final String name;
  final String cnic;
  final String age;
  final String phone;
  final String occupation;
  final String password;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.cnic,
    required this.age,
    required this.phone,
    required this.occupation,
    required this.password
});

  factory UserModel.fromJson(Map<String,dynamic> json){
    return UserModel(
        uid: json['uid'],
        email: json['email'],
        name: json['name'],
        cnic: json['cnic'],
        age: json['age'],
        phone: json['phone'],
        occupation: json['occupation'],
        password: json['password']);
  }

  Map<String,dynamic> toJson(){
    return {
      'uid':uid,
      'email':email,
      'name':name,
      'cnic':cnic,
      'age':age,
      'phone':phone,
      'occupation':occupation,
      'password':password
    };
  }

}