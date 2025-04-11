import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../helpers/EncryptionHelper.dart';

class AddPatientScreen extends StatefulWidget {
  final String imagePath;
  final String result;

  const AddPatientScreen({
    super.key,
    required this.imagePath,
    required this.result,
  });

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
        margin: pw.EdgeInsets.all(10),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                "ECG Report",
                style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 15),
              pw.Text(
                "Result: ${widget.result}",
                style: pw.TextStyle(fontSize: 18),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 15),
              pw.Container(
                width: PdfPageFormat.a4.width - 20,
                height: PdfPageFormat.a4.height * 0.7,
                child: pw.Image(image, fit: pw.BoxFit.contain),
              ),
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
    if (_nameController.text.isEmpty || _cnicController.text.isEmpty || _phoneController.text.isEmpty || _ageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required!")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String encryptedName = await EncryptionHelper.encryptData(_nameController.text.trim());
      String encryptedPhone = await EncryptionHelper.encryptData(_phoneController.text.trim());
      String encryptedAge = await EncryptionHelper.encryptData(_ageController.text.trim());

      await FirebaseFirestore.instance.collection("Patients").add({
        "name": encryptedName,
        "cnic": _cnicController.text.trim(), // CNIC stored in plain text
        "phone": encryptedPhone,
        "age": encryptedAge,
        "createdAt": DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Patient Data Saved Successfully")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: ${e.toString()}")));
    } finally {
      setState(() => _isSaving = false);
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
              if (_pdfPath != null)
                Center(
                  child: IconButton(
                    icon: Icon(Icons.picture_as_pdf, color: Colors.red, size: 60),
                    onPressed: _openPDF,
                  ),
                ),
              SizedBox(height: 30),
              Center(
                child: _isSaving
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _savePatientData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          textStyle: TextStyle(fontSize: 18),
                        ),
                        child: Text("Save"),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
