import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_viz/results_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/results_screen.dart';



class ModelController {
  
  bool isLoading = false; // This will track if loading is active

  final imagePicker = ImagePicker();
  final String baseUrl = 'http://13.51.157.252:5000/predict';
  bool? predictionResult;
  
  String imagePath = ''; // Add this line at the top of the class

Future<String> pickAndSendImage(WidgetRef ref, BuildContext context) async {
  ref.read(isLoadingProvider.notifier).state = true;

  XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    imagePath = image.path; // Store the selected image path
    File imageFile = File(imagePath);
    var response = await sendImageToApi(imageFile);
    ref.read(isLoadingProvider.notifier).state = false;

    if (response != null) {
      predictionResult = response;
      String result = predictionResult == true ? 'HeartAttack' : 'Normal';

      // Navigate to ResultsScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(imagePath: imagePath),
        ),
      );

      return result;
    } else {
      return 'Error occurred';
    }
  } else {
    ref.read(isLoadingProvider.state).state = false;
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