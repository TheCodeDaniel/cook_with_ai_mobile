import 'package:cooking/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //flutter cannot initialize firease without this line
  await Firebase.initializeApp(); // initialize firebase in your project
  runApp(MyApp());
}
