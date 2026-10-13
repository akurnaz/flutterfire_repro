import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initializing with demoProjectId as documented for Firebase Local Emulator
  // without any remote Firebase project:
  await Firebase.initializeApp(
    demoProjectId: 'demo-template',
  );

  runApp(const MaterialApp(
    home: Scaffold(
      body: Center(
        child: Text('Firebase Initialized Successfully!'),
      ),
    ),
  ));
}
