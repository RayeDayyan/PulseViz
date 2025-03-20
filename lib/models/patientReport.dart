import 'package:cloud_firestore/cloud_firestore.dart';

class PatientReport {
  final String name;
  final String cnic;
  final String phone;
  final int age;
  final String ecgResult;
  final String ecgImageUrl; // ✅ Added missing field
  final DateTime createdAt;

  PatientReport({
    required this.name,
    required this.cnic,
    required this.phone,
    required this.age,
    required this.ecgResult,
    required this.ecgImageUrl, // ✅ Added to constructor
    required this.createdAt,
  });

  // ✅ Fix: Add copyWith method
  PatientReport copyWith({
    String? name,
    String? cnic,
    String? phone,
    int? age,
    String? ecgResult,
    String? ecgImageUrl, // ✅ Added to copyWith
    DateTime? createdAt,
  }) {
    return PatientReport(
      name: name ?? this.name,
      cnic: cnic ?? this.cnic,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      ecgResult: ecgResult ?? this.ecgResult,
      ecgImageUrl: ecgImageUrl ?? this.ecgImageUrl, // ✅ Ensures new property is handled
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "cnic": cnic,
      "phone": phone,
      "age": age,
      "ecg_result": ecgResult, // Fixed key consistency
      "ecg_image_url": ecgImageUrl, // ✅ Added field to Firestore mapping
      "createdAt": Timestamp.fromDate(createdAt), // Convert DateTime to Timestamp
    };
  }

  static PatientReport fromMap(Map<String, dynamic> map) {
    return PatientReport(
      name: map["name"],
      cnic: map["cnic"],
      phone: map["phone"],
      age: map["age"],
      ecgResult: map["ecg_result"], // Fixed key consistency
      ecgImageUrl: map["ecg_image_url"], // ✅ Extract from Firestore map
      createdAt: (map["createdAt"] as Timestamp).toDate(), // Convert Timestamp to DateTime
    );
  }
}
