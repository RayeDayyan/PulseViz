import 'package:flutter/material.dart';
import '../controllers/patientController.dart';
import '../models/patientReport.dart';

class SearchPatientScreen extends StatefulWidget {
  const SearchPatientScreen({super.key});

  @override
  _SearchPatientScreenState createState() => _SearchPatientScreenState();
}

class _SearchPatientScreenState extends State<SearchPatientScreen> {
  final TextEditingController _cnicController = TextEditingController();
  List<PatientReport>? _patientReports;
  bool _isLoading = false;

  void _searchPatient() async {
  setState(() => _isLoading = true);

  String cnic = _cnicController.text.trim();
  DatabaseService dbService = DatabaseService();

  // ✅ Check if CNIC exists in the database before fetching reports
  bool cnicExists = await dbService.checkIfCnicExists(cnic);

  if (!cnicExists) {
    if (mounted) {
      setState(() {
        _patientReports = []; // Clear previous results
        _isLoading = false;
      });

      // Show error message if CNIC is not found
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ CNIC not found! Please enter a valid CNIC."),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  // ✅ If CNIC exists, fetch reports
  List<PatientReport> reports = await dbService.getPatientReportsByCNIC(cnic);

  if (mounted) {
    setState(() {
      _patientReports = reports;
      _isLoading = false;
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Patient Report")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _cnicController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "Enter CNIC"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _searchPatient,
              child: Text("Search"),
            ),
            SizedBox(height: 20),
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_patientReports != null && _patientReports!.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _patientReports!.length,
                  itemBuilder: (context, index) {
                    final report = _patientReports![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        title: Text("ECG Result: ${report.ecgResult}", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Name: ${report.name}"),
                            Text("CNIC: ${report.cnic}"),
                            Text("Phone: ${report.phone}"),
                            Text("Age: ${report.age}"),
                            Text("ECG Image URL: ${report.ecgImageUrl}"),
                            Text("Created At: ${report.createdAt}"),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Center(child: Text("No record found", style: TextStyle(color: Colors.red, fontSize: 16))),
          ],
        ),
      ),
    );
  }
}
