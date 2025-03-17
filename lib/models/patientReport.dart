import 'package:cloud_firestore/cloud_firestore.dart';

class PatientReport {

final String name;
final String cnic;
final String phone;
final int age;
final String ecgResult;
final DateTime createdAt;

PatientReport({
  required this.name,
  required this.cnic,
  required this.phone,
  required this.age,
  required this.ecgResult,
  required this.createdAt,
});

Map<String, dynamic> toMap() {
  return {
    "name" : name,
    "cnic" : cnic,
    "phone" : phone,
    "age" : age,
    "ecg_result" : ecgResult,
    "createdAt" : createdAt, 
  };
}

static PatientReport fromMap (Map<String, dynamic> map){
  return PatientReport(
        name: map["name"], 
        cnic: map["cnic"], 
        phone: map["phone"],
        age: map["age"], 
        ecgResult: map["ecgResult"],
        createdAt: (map["createdAt"] as Timestamp).toDate(),
        );
}

}