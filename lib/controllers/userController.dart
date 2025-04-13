import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pulse_viz/models/userModel.dart';
import 'package:pulse_viz/helpers/EncryptionHelper.dart';

class UserController {
  final FirebaseFirestore firestore = FirebaseFirestore.instance; // Define Firestore here
  final auth = FirebaseAuth.instance;
  
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
  
  Future<UserModel?> fetchCurrentUser() async{
    try{
      final currentUserID = await auth.currentUser?.uid;
      
      final currentUser = await firestore.collection('users').doc(currentUserID).get();

      final user = await UserModel.fromJson(currentUser.data()!);

      return user;

      
      
    }catch(e){
      print('Error occured while fetching current user $e');
      return null;
    }
  }

  Future<void> updateDutyStatus(bool dutyStatus) async{
    try{
      final uid = auth.currentUser!.uid;

      await firestore.collection('users').doc(uid).update({
        'onDuty':dutyStatus,
      });

    }catch(e){
      print('Error occured');
    }
  }
}
