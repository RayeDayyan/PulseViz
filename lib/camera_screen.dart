import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/modelController.dart'; // Import the model controller file
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
  final modelController = ModelController(); // ModelController instance

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras found");
      }
      final camera = cameras.first;
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController?.lockCaptureOrientation(); 

      if (mounted) {
        setState(() {}); 
      }
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
      print("Image captured successfully: ${imageFile.path}");

      File image = File(imageFile.path);
      print("Checking if file exists: ${image.existsSync()}"); // Debugging      
      // Call API using ModelController
      String result = await modelController.captureAndSendImage(image, ref, context);

      setState(() {
        _scanResult = result;
      });

      print("API Result: $_scanResult");
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
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && _cameraController != null) {
            return Stack(
              children: [
                // ✅ Camera Preview
                Positioned.fill(
                  child: RotatedBox(
                    quarterTurns: 0, // Portrait Mode
                    child: CameraPreview(_cameraController!),
                  ),
                ),

                // ✅ Overlay Instructions
                Positioned(
                  top: 50,
                  left: 20,
                  right: 20,
                  child: Column(
                    children: [
                      Text(
                        "Keep ECG strip within the lines",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "Avoid glare and shadows for best results",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

Positioned(
  top: MediaQuery.of(context).size.height * 0.15, // Lowered to center better
  left: 20,
  right: 20,
  child: SizedBox(
    height: MediaQuery.of(context).size.height * 0.65, // Increased height
    width: MediaQuery.of(context).size.width * 0.9, // Wide enough for ECG images
    child: Stack(
      children: [
        // Top-Left Corner
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.red, width: 4),
                left: BorderSide(color: Colors.red, width: 4),
              ),
            ),
          ),
        ),
        // Top-Right Corner
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.red, width: 4),
                right: BorderSide(color: Colors.red, width: 4),
              ),
            ),
          ),
        ),
        // Bottom-Left Corner
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.red, width: 4),
                left: BorderSide(color: Colors.red, width: 4),
              ),
            ),
          ),
        ),
        // Bottom-Right Corner
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 50,
            height: 50,
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.red, width: 4),
                right: BorderSide(color: Colors.red, width: 4),
              ),
            ),
          ),
        ),
      ],
    ),
  ),
),




                // ✅ Capture Button
                Positioned(
                  bottom: 20,
                  left: MediaQuery.of(context).size.width / 2 - 30,
                  child: Consumer(
                    builder: (context, ref, child) => FloatingActionButton(
                      onPressed: () => _captureAndProcessImage(ref),
                      backgroundColor: Colors.redAccent,
                      child: const Icon(Icons.camera),
                    ),
                  ),
                ),

                // ✅ Display API Result
                Positioned(
                  bottom: 100,
                  left: 20,
                  child: Text(
                    _scanResult,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Camera Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.white),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
