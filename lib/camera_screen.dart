import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:pulse_viz/controllers/report_provider.dart';
import 'package:pulse_viz/search_patient.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  late Future<void> _initializeControllerFuture;
  String _scanResult = "";
  final modelController = ModelController();

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) throw Exception("No cameras found");
      
      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );
      
      await _cameraController!.initialize();
      await _cameraController?.lockCaptureOrientation();
      if (mounted) setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _captureAndProcessImage(WidgetRef ref) async {
    try {
      if (_cameraController == null || !_cameraController!.value.isInitialized) {
        print("Camera isn't initialized");
        return;
      }

      final XFile imageFile = await _cameraController!.takePicture();
      File image = File(imageFile.path);
      ref.read(imageProvider.state).state = image;
      String result = await modelController.captureAndSendImage(image, ref, context);

      setState(() {
        _scanResult = result;
      });
    } catch (error) {
      print("Error while capturing and processing image: $error");
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Image.asset('assets/images/red_logo.png'),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchPatientScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _cameraController != null) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_cameraController!)),

                /// 🟢 Frame Overlay
                Positioned.fill(
                  child: CustomPaint(
                    painter: FramePainter(),
                  ),
                ),

                /// 🟡 Instructions
                Positioned(
                  top: 10,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        "Keep ECG paper inside the frame",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 2),
                      Text(
                        "Ensure good lighting & avoid glare",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                /// 🔴 Capture Button
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: Consumer(
                    builder: (context, ref, child) => FloatingActionButton(
                      onPressed: () => _captureAndProcessImage(ref),
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.camera),
                    ),
                  ),
                ),

                /// 🔵 Scan Result Display
                Positioned(
                  bottom: 100,
                  left: 20,
                  child: Text(
                    _scanResult,
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Camera Error: ${snapshot.error}",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}

/// 🎨 Custom Painter for Open Frame with Corner Edges
class FramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.redAccent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke;

    final double frameWidth = size.width * 0.9; // Max 80% of screen width
    final double frameHeight = size.height * 0.85; // Max 50% of screen height
    final double left = (size.width - frameWidth) / 2;
    final double top = (size.height - frameHeight) / 2;
    final double cornerLength = 40; // Length of corner lines

    /// Draw corners instead of full rectangle
    final Path path = Path()
      // Top Left
      ..moveTo(left, top + cornerLength)
      ..lineTo(left, top)
      ..lineTo(left + cornerLength, top)

      // Top Right
      ..moveTo(left + frameWidth - cornerLength, top)
      ..lineTo(left + frameWidth, top)
      ..lineTo(left + frameWidth, top + cornerLength)

      // Bottom Left
      ..moveTo(left, top + frameHeight - cornerLength)
      ..lineTo(left, top + frameHeight)
      ..lineTo(left + cornerLength, top + frameHeight)

      // Bottom Right
      ..moveTo(left + frameWidth - cornerLength, top + frameHeight)
      ..lineTo(left + frameWidth, top + frameHeight)
      ..lineTo(left + frameWidth, top + frameHeight - cornerLength);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
