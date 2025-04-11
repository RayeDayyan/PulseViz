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
    QuerySnapshot reportSnapshots =
        await patientCollection.doc(cnic).collection("reports").get();

    return reportSnapshots.docs.map((doc) {
      return PatientReport(
        name: "", // Name isn't stored in reports, it's in the main document
        cnic: cnic,
        phone: "", // Not needed for each report
        age: 0, // Not needed for each report
        ecgResult: doc['ecgResult'],
        ecgImageUrl: doc['ecgImageUrl'],
        createdAt: (doc['createdAt'] as Timestamp).toDate(),
      );
    }).toList();
  }

Future<bool> checkIfCnicExists(String cnic) async {
  var patientCollection = FirebaseFirestore.instance.collection("patients");

  print("🔍 Checking CNIC: $cnic");

  // Fetch all patient records
  var snapshot = await patientCollection.get();

  // Debug: Print all stored CNICs
  for (var doc in snapshot.docs) {
    print("🗂️ Stored CNIC: ${doc.id}"); // Print each CNIC stored in Firestore
  }

  // Check if the CNIC exists
  bool exists = snapshot.docs.any((doc) => doc.id == cnic);
  
  print("🔍 CNIC Exists: $exists");
  return exists;
}

}
