import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart'; // Import Firebase Core
import 'firebase_options.dart'; // Import the generated Firebase options file
import 'splash_screen.dart';
import 'video_data.dart';

// The main entry point of the application.
Future<void> main() async {
  // Ensure that the Flutter binding is initialized before running the app.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options for the current platform.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local data storage.
  await Hive.initFlutter();
  // Register the custom adapter for the VideoData class.
  Hive.registerAdapter(VideoDataAdapter());
  // Open a Hive box to store VideoData objects.
  await Hive.openBox<VideoData>('video_data_box');
  // Open a Hive box to store user-added video paths.
  await Hive.openBox<String>('user_videos_box');

  // Run the main application widget.
  runApp(const MyApp());
}

// The root widget of the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // The title of the application.
      title: 'Personal Reel Gallery',
      // Hide the debug banner in the top-right corner.
      debugShowCheckedModeBanner: false,
      // Define the theme for the application.
      theme: ThemeData(
        // Use a dark theme.
        brightness: Brightness.dark,
        // Set the primary color swatch.
        primarySwatch: Colors.blue,
      ),
      // Set the initial screen of the application to SplashScreen.
      home: const SplashScreen(),
    );
  }
}