import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; 

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;
  Interpreter? _interpreter; 
  String _scanResult = "";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _loadModel(); 
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception("No cameras found");
      }
      final camera = cameras.first;
      _cameraController = CameraController(camera, ResolutionPreset.high);
      _initializeControllerFuture = _cameraController?.initialize();
      await _initializeControllerFuture;
      setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }

  Future<void> _loadModel() async 
  { 
    try {
      _interpreter = await Interpreter.fromAsset("assets/model.tflite");
      print("Model loaded successfully");
    } catch (e) {
      print("Error loading model: $e");
    }
  }

  Future<void> _captureAndProcessImage() async{
     try
     {
       if(_cameraController == null || !_cameraController!.value.isInitialized)
       {
        print("Camera isn't initialized");
        return;
       }

       final XFile imageFile = await _cameraController!.takePicture();
       final imageBytes = await imageFile.readAsBytes();
       print("Image captured successfully.");

       var input = _preprocessImage(imageBytes);
       var output = List.filled(1, 0.0).reshape([1, 1]); 

       _interpreter?.run(input, output);
       print("Inference result:  $output");
       setState(() {
         _scanResult = output.toString();
       });
     }
     catch(error)
     {
        print("Error while capturing and processing image : $error");
     }
  }

Uint8List _preprocessImage(Uint8List imageBytes) {
  img.Image image = img.decodeImage(imageBytes)!;
  img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

  var buffer = Float32List(224 * 224 * 3);
  for (int i = 0; i < 224; i++) {
    for (int j = 0; j < 224; j++) {
      img.Pixel pixel = resizedImage.getPixelSafe(j, i); 
      
      int r = pixel.r.toInt(); 
      int g = pixel.g.toInt(); 
      int b = pixel.b.toInt();

      buffer[i * 224 * 3 + j * 3] = r / 255.0;
      buffer[i * 224 * 3 + j * 3 + 1] = g / 255.0;
      buffer[i * 224 * 3 + j * 3 + 2] = b / 255.0;
    }
  }

  return buffer.buffer.asUint8List();
}



  @override
  void dispose() {
    _cameraController?.dispose();
    _interpreter?.close(); 
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
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_cameraController!)),

                Positioned(
                  bottom : 20,
                  left : MediaQuery.of(context).size.width / 2 - 30,
                  child: FloatingActionButton(
                    onPressed: _captureAndProcessImage,
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.camera),
                  )
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
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
