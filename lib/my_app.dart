// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:appwrite_demo/chat_screen.dart';

import 'core/screens/chat_screen.dart';
import 'login_screen.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      // home: SizedBox(),
      home: LoginScreen(),
    );
  }
}
