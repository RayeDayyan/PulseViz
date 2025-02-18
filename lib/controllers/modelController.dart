import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class ModelController {

  final imagePicker = ImagePicker();
  final String baseUrl = 'http://13.51.157.252:5000/predict';
  bool? predictionResult;


  Future<String> pickAndSendImage() async {
    // Pick image from gallery
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File imageFile = File(image.path);
      // Send image to Python API
      var response = await sendImageToApi(imageFile);

      //return response depending on what we got from the api call,true for heartattack and false for normal heatbeat
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
    var uri = Uri.parse(baseUrl);  // creating our Uri to send a multipart request
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));


    try {
      var response = await request.send();

      //on successful api hit and getting the response, handle what the api gives as result respectively
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