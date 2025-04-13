
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pulse_viz/controllers/userController.dart';
import 'package:pulse_viz/models/userModel.dart';

final currentUserDetails = FutureProvider<UserModel?>((ref)async{
  final userController = UserController();
  final result = await userController.fetchCurrentUser();
  return result;
});