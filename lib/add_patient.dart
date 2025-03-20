import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../controllers/patientController.dart';
import '../models/patientReport.dart';

class AddPatientScreen extends StatefulWidget {
  final String imagePath;
  final String result;

  const AddPatientScreen({
    Key? key,
    required this.imagePath,
    required this.result,
  }) : super(key: key);

  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  
  String? _pdfPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _generatePDF();
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    final image = pw.MemoryImage(File(widget.imagePath).readAsBytesSync());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("ECG Report", style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text("Result: ${widget.result}", style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 20),
              pw.Image(image, width: 400, height: 200),
            ],
          );
        },
      ),
    );

    final output = await getApplicationDocumentsDirectory();
    final pdfFile = File("${output.path}/ECG_Report.pdf");
    await pdfFile.writeAsBytes(await pdf.save());

    setState(() {
      _pdfPath = pdfFile.path;
    });
  }

  void _openPDF() {
    if (_pdfPath != null) {
      OpenFile.open(_pdfPath);
    }
  }

  void _savePatientData() async {
    if (_nameController.text.isEmpty ||
        _cnicController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _ageController.text.isEmpty ||
        _pdfPath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      PatientReport newPatient = PatientReport(
        name: _nameController.text.trim(),
        cnic: _cnicController.text.trim(),
        phone: _phoneController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        ecgResult: widget.result,
        ecgImageUrl: _pdfPath!,
        createdAt: DateTime.now(),
      );

      await DatabaseService().addPatientReport(newPatient);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient Data Saved Successfully")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving data: ${e.toString()}")),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Patient Report")),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Patient Name"),
              ),
              TextField(
                controller: _cnicController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "CNIC"),
              ),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: "Phone Number"),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Age"),
              ),
              SizedBox(height: 20),
              
              // **Clickable PDF Link**
              if (_pdfPath != null)
                TextButton(
                  onPressed: _openPDF,
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf, color: Colors.red),
                      SizedBox(width: 8),
                      Text("View ECG Report PDF"),
                    ],
                  ),
                ),

              SizedBox(height: 20),
              _isSaving
                  ? Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _savePatientData,
                      child: Text("Save"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}