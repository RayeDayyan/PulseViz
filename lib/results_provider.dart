import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/controllers/modelController.dart';

final modelController = ModelController();

final resultsProvider = StateProvider<String>((ref){
  return 'Nothing yet';
});