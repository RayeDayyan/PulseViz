import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/controllers/modelController.dart';
import 'package:pulse_viz/models/report_model.dart';
import 'dart:io';

final modelController = ModelController();

final imageProvider = StateProvider<File?>((ref){
  return null;
});

final reportProvider = FutureProvider<Report?>((ref) async {
  print('in report provider');
  final image = ref.read(imageProvider.state).state;
  print(image);
  return await modelController.getGenerationResults(image!);
});