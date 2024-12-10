import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';


class ModelController {
  void pickAndPredict() async{
    final imagePicker = ImagePicker();
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if(image!=null){
      await predictHeartAttack(image.path);
    }else{
      return;
    }
  }

  Future<void> predictHeartAttack(String imagePath) async {
    // Preprocess the image
    img.Image? preprocessedImage = preprocessImage(imagePath);


    if (preprocessedImage == null) {
      return;
    }


    final tempPath = await saveImageToTempFile(preprocessedImage);
    // Run the model on the processed image
    var output = await Tflite.runModelOnImage(path: tempPath);
    print('outputtt');
    print(output);
    // Interpret the result (assuming output is a single value between 0 and 1)
    if (output != null && output.isNotEmpty) {
      var prediction = output[0];
      if (prediction > 0.5) {
        print('Model predicted Heart Attack');
      } else {
        print('Model predicted Normal Heartbeat');
      }
    } else {
      print('Prediction failed');
    }
  }


  img.Image? preprocessImage(String imagePath) {
    // Read the image file
    img.Image image = img.decodeImage(File(imagePath).readAsBytesSync())!;

    // Resize to 720x720
    image = img.copyResize(image, width: 720, height: 720);

    // Convert to grayscale if it's not already
    image = img.grayscale(image);

    // Normalize pixel values to [0, 1] range




    return image;
  }

  Future<String> saveImageToTempFile(img.Image image) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/processed_image.jpg');

    // Save the preprocessed image as a jpg file
    await tempFile.writeAsBytes(img.encodeJpg(image));

    return tempFile.path;
  }





}