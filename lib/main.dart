import 'package:flutter/material.dart';
import 'screens/rsa_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSA Dosya Şifreleme Uygulaması',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const RSAPage(),
    );
  }
}
