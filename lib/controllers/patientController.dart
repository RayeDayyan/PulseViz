import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patientReport.dart';

class DatabaseService {
  final CollectionReference patientCollection =
      FirebaseFirestore.instance.collection('Patients');

  // ✅ Function to add a new patient report
  Future<void> addPatientReport(PatientReport report) async {
    // Reference to the patient's document using CNIC
    DocumentReference patientRef = patientCollection.doc(report.cnic);

    // Ensure the patient exists (or create if not)
    await patientRef.set({
      'name': report.name,
      'cnic': report.cnic,
      'phone': report.phone,
      'age': report.age,
    }, SetOptions(merge: true)); // ✅ Ensures patient info is updated without overwriting reports

    // Add the ECG report inside the "reports" subcollection
    await patientRef.collection("reports").add({
      'ecgResult': report.ecgResult,
      'ecgImageUrl': report.ecgImageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return; // ✅ Explicitly return void to match function signature
  }

  // ✅ Function to fetch all reports for a specific CNIC
Future<List<PatientReport>> getPatientReportsByCNIC(String cnic) async {
  final patientDoc = await patientCollection.doc(cnic).get();
  print("📄 patientDoc.exists=${patientDoc.exists}");
  
  final snap = await patientCollection.doc(cnic).collection('reports').get();
  print("📊 Found ${snap.docs.length} reports for CNIC=$cnic");
  
  if (!patientDoc.exists || snap.docs.isEmpty) return [];

  final patientData = patientDoc.data() as Map<String, dynamic>;
  final name = patientData['name'] ?? '';
  final phone = patientData['phone'] ?? '';
  final age = int.tryParse(patientData['age'].toString()) ?? 0;

  // Get all reports for this patient
  QuerySnapshot reportSnapshots = await patientCollection
      .doc(cnic)
      .collection("reports")
      .orderBy("createdAt", descending: true)
      .get();

  return reportSnapshots.docs.map((doc) {
    return PatientReport(
      name: name,
      cnic: cnic,
      phone: phone,
      age: age,
      ecgResult: doc['ecgResult'],
      ecgImageUrl: doc['ecgImageUrl'],
      createdAt: (doc['createdAt'] as Timestamp).toDate(),
    );
  }).toList();
}


Future<bool> checkIfCnicExists(String cnic) async {
  final doc = await patientCollection.doc(cnic).get();
  print("🔍 checkIfCnicExists: doc.exists=${doc.exists} (CNIC=$cnic)");
  return doc.exists;
}



}
