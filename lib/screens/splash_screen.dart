import 'package:flutter/material.dart';
import '../config/routes.dart';
import '../utils/firebase_helper.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkFirebase();
  }

  Future<void> _checkFirebase() async {
    bool isConnected = await FirebaseHelper.checkConnection();
    if (isConnected) {
      // Always navigate to transaction screen after splash
      if (mounted) {
        Navigator.pushReplacementNamed(context, Routes.transaction);
      }
    } else {
      // Show error if Firebase connection fails
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect to Firebase')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFFF5252), // Warna merah yang sesuai dengan gambar
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100, // Sesuaikan ukuran sesuai kebutuhan
              height: 100,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/icon_pig.png'),
                  fit: BoxFit.contain, // Warna ikon putih
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
