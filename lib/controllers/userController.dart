import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:pulse_viz/helpers/EncryptionHelper.dart';

class UserController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Define Firestore here

  Future<bool> signUpUser(UserModel user) async {
    try {
      String cnic = user.cnic;
      String encryptedPhone = await EncryptionHelper.encryptData(user.phone);

      await firestore.collection('users').doc(user.uid).set(
        user.toJsonSync(cnic: cnic, encryptedPhone: encryptedPhone),
      );

      return true;
    } catch (e) {
      print('Error occurred: $e');
      return false;
    }
  }
}
