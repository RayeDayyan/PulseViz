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
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isModelLoaded = false;


  @override
  void initState() {
    super.initState();
    _loadModel();
    _initializeCamera();
  }

  Future<void> _loadModel() async {
    String? res = await Tflite.loadModel(model: 'assets/models/model.tflite');
    if (res != null) {
     setState(() {
        _isModelLoaded = true;
      });
    }
  }


  Future<void> _initializeCamera() async{
    final cameras = await availableCameras();
    final camera = cameras.first;
    
    _cameraController = CameraController(camera, ResolutionPreset.high);

    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _cameraController.dispose();
    Tflite.close();
    super.dispose();
  }


  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: Image.asset('assets/images/red_logo.png'),
        backgroundColor: Colors.black,
      ),
      body: _isModelLoaded?
      FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context,snapshot){
          if(snapshot.connectionState==ConnectionState.done){
            return Stack(
              children: [
                Positioned.fill(child: CameraPreview(_cameraController))
              ],
            );
          }else{
            return Center(child: CircularProgressIndicator(),);
          }
        },
      )
      :Center(child: CircularProgressIndicator(),),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}