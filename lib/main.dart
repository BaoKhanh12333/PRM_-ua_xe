import 'package:flutter/material.dart';
import 'screens/auth_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RacingGameApp());
}

class RacingGameApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Siêu Cấp Đua Xe',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.red,
        scaffoldBackgroundColor: Color(0xFF1a1a2e),
        fontFamily: 'Roboto',
      ),
      home: AuthScreen(),
    );
  }
}