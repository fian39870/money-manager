import 'package:firebase_core/firebase_core.dart';

class FirebaseHelper {
  static Future<bool> checkConnection() async {
    try {
      // Cek koneksi ke Firebase
      await Firebase.initializeApp();
      return true;
    } catch (e) {
      print('Error connecting to Firebase: $e');
      return false;
    }
  }
}
