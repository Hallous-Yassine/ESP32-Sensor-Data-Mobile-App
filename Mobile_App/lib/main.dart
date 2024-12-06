import 'package:flutter/material.dart';
import 'splash_page.dart';

const String SERVER_IP_ADDRESS = '192.168.1.2'; // Replace with your actual IP address

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ESP32 Project',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SplashScreen(ipAddress: SERVER_IP_ADDRESS),
    );
  }
}
