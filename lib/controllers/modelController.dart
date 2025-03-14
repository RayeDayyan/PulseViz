import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:pulse_viz/results_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:pulse_viz/results_screen.dart';
import 'package:pulse_viz/loading_screen.dart';

class ModelController {
  bool isLoading = false;
  final imagePicker = ImagePicker();
  final String baseUrl = 'http://13.51.157.252:5000/predict';
  bool? predictionResult;
  String imagePath = '';

  Future<String> pickAndSendImage(WidgetRef ref, BuildContext context) async {
    ref.read(isLoadingProvider.notifier).state = true;
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      imagePath = image.path;
      File imageFile = File(imagePath);

      if (!imageFile.existsSync()) {
        print("🚨 Error: Selected image file does not exist!");
        ref.read(isLoadingProvider.notifier).state = false;
        return 'Error: File does not exist';
      }

      var response = await sendImageToApi(imageFile);
      ref.read(isLoadingProvider.notifier).state = false;

      if (response != null) {
        predictionResult = response;
        String result = predictionResult == true ? 'HeartAttack' : 'Normal';

        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultsScreen(imagePath: imagePath),
            ),
          );
        });
        return result;
      } else {
        return 'Error occurred';
      }
    } else {
      ref.read(isLoadingProvider.notifier).state = false;
      return 'No Image Selected';
    }
  }

Future<String> captureAndSendImage(File imageFile, WidgetRef ref, BuildContext context) async {
  print("📸 Captured Image Path: ${imageFile.path}");

  if (!imageFile.existsSync()) {
    print("🚨 Error: Captured image file does not exist!");
    return "Error: Captured image file does not exist!";
  }

  // ✅ Show loading screen before API call
  ref.read(isLoadingProvider.notifier).state = true;
  print("⏳ Navigating to Loading Screen");

  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const LoadingScreen()),
  );

  try {
    await Future.delayed(Duration(milliseconds: 500)); // Ensure UI updates

    var response = await sendImageToApi(imageFile);

    if (response != null) {
      predictionResult = response;
      String result = predictionResult == true ? 'HeartAttack' : 'Normal';

      print("✅ API Prediction Result: $result");

      // ✅ Update resultsProvider before navigating
      ref.read(resultsProvider.notifier).state = result;

      // ✅ Close loading screen and navigate to results
      Navigator.pop(context); // Remove LoadingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ResultsScreen(imagePath: imageFile.path),
        ),
      );

      return result;
    } else {
      print("🚨 API Response Error: Received null");
      return 'Error occurred';
    }
  } catch (e) {
    print("🚨 Exception in captureAndSendImage: $e");
    return "Error processing image";
  } finally {
    // ✅ Ensure loader state is turned off
    ref.read(isLoadingProvider.notifier).state = false;
    print("✅ Loader Deactivated");
  }
}



  Future<bool?> sendImageToApi(File imageFile) async {
    var uri = Uri.parse(baseUrl);
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await response.stream.bytesToString();
        print("🔄 API Raw Response: $responseData");
        var result = jsonDecode(responseData);

        if (result is Map<String, dynamic> && result.containsKey('result')) {
        return result['result'] == true;
      } else {
        print("🚨 Unexpected API Response: $result");
        return null;
      }
    } else {
      print("❌ Error: API responded with status ${response.statusCode}");
      return null;
    }
  } catch (e) {
    print("⚠️ Error in sendImageToApi: $e");
    return null;
  }
  }
}
