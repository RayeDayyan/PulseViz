import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/bottom_navigation.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:tflite_v2/tflite_v2.dart';


class CameraScreen extends StatefulWidget{
  @override
  State<CameraScreen> createState() => CameraScreenState();
}

class CameraScreenState extends State<CameraScreen>{
  CameraController? _cameraController;
  Future<void>? _initializeControllerFuture;


  @override
  void initState() {
    super.initState();
    //initialize the app when the state of the screen is built first
    _initializeCamera();
  }



  Future<void> _initializeCamera() async {
    try {
      //look for available cameras
      final cameras = await availableCameras();

      //throw exception if the cameras are not found
      if (cameras.isEmpty) {
        throw Exception("No cameras found");
      }

      //initialize the controllers with the first camera
      final camera = cameras.first;
      _cameraController = CameraController(camera, ResolutionPreset.high);
      _initializeControllerFuture = _cameraController?.initialize();
      await _initializeControllerFuture;

      setState(() {});
    } catch (e) {
      print("Camera initialization error: $e");
    }
  }


  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
    super.dispose();
  }


  @override
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
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
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