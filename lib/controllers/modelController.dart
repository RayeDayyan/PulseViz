import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class ModelController {

  final imagePicker = ImagePicker();
  final String baseUrl = 'http://10.0.2.2:5000/predict';
  bool? predictionResult;

  Future<String> pickAndSendImage() async {
    // Pick image from gallery
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      // Send image to Python API
      var response = await sendImageToApi(imageFile);

      if (response != null) {
          predictionResult = response;
          if(predictionResult==true){
              return 'HeartAttack';
          }else{
              return 'Normal';
          }
      } else {
        // Handle error
        print("Prediction failed");
        return 'Error occured';
      }
    } else {
      // Handle case where no image was selected
      return 'No Image Selected';
    }
  }

  Future<bool?> sendImageToApi(File imageFile) async {
    var uri = Uri.parse(baseUrl);  // Replace with your API URL
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));


    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        // Parse the response
        var responseData = await response.stream.bytesToString();
        var result = jsonDecode(responseData);
        return result['result'];
      } else {
        print("Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Error: $e");
      return null;
    }
  }

}