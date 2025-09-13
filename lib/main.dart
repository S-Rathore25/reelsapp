import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // Firebase import karein
import 'firebase_options.dart'; // Generated file import karein
import 'splash_screen.dart';
import 'video_data.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase ko initialize karein
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive ko initialize karein
  await Hive.initFlutter();
  Hive.registerAdapter(VideoDataAdapter());
  await Hive.openBox<VideoData>('video_data_box');
  await Hive.openBox<String>('user_videos_box');

  runApp(const MyApp());
}

// ... MyApp class me koi badlav nahi
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Reel Gallery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
    );
  }
}