import 'package:flutter/material.dart';

import 'pages/signup_page.dart';

void main() {
  runApp(const FarmTabApp());
}

class FarmTabApp extends StatelessWidget {
  const FarmTabApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FarmTab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const SignupPage(),
    );
  }
}