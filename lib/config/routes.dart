import 'package:flutter/material.dart';
import '../screens/splash_screen.dart';
import '../screens/transaction_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/setting_screen.dart';

class Routes {
  static const String splash = '/';
  static const String transaction = '/transaction';
  static const String login = '/login';
  static const String setting = '/registration';
  static const String signup = '/signup';

  static Map<String, Widget Function(BuildContext)> getRoutes() {
    return {
      splash: (_) => SplashScreen(),
      transaction: (_) => TransactionScreen(),
      login: (_) => LoginPage(),
      setting: (_) => SettingPage(),
      signup: (_) => SignUpPage(),
    };
  }
}
