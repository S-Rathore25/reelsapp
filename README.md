Personal Reel Gallery Reels App 🎞️
Welcome to the Personal Reel Gallery, a Flutter-based mobile application designed to provide a user experience similar to Instagram Reels or TikTok. This app allows users to create a personal gallery of short video clips by adding them from their device. It features a vertically scrollable video feed, user authentication, and local data persistence for a seamless experience.

✨ Features
User Authentication: Secure sign-up and login functionality using Firebase Authentication.

Vertical Video Feed: A smooth, vertically swiping reel player for an engaging viewing experience.

Add Videos: Users can pick videos from their phone's gallery and add them to their personal reel feed.

Video Grid: View all your added videos in a convenient grid layout for easy navigation.

Local Storage: Utilizes Hive for fast and efficient local storage of video metadata and paths.

Persistent Data: Likes, comments, and other video data are saved locally on the device.

Delete Videos: Users can remove videos from their gallery.

🏛️ Brief Architecture Notes
This application is built using Flutter and follows a simple yet effective architecture.

State Management: The app primarily uses StatefulWidget and the setState mechanism for managing local UI state. This approach is suitable for the current scale of the application.

Backend & Authentication: Firebase Authentication is used for handling all user-related operations like registration and login. The app features an AuthGate widget that acts as a listener to the user's authentication state, directing them to either the login screen or the main reels page.

Local Database: Hive is integrated as a lightweight and fast key-value database. It is used for two main purposes:

Storing the file paths of videos that the user adds from their gallery.

Persisting metadata for each video (e.g., likes, comments) in a VideoData object.

Code Generation: The project uses the build_runner package to generate adapter code for Hive (.g.dart files), which ensures type safety and performance.

Navigation: Standard Flutter navigation (MaterialPageRoute, Navigator) is used for screen transitions.

🔧 Backend Setup (Firebase)
This project does not require a traditional mock server. Instead, it uses Firebase as its backend for authentication. To run the app, you need to set up your own Firebase project.

Create a Firebase Project:

Go to the Firebase Console.

Click on "Add project" and follow the on-screen instructions to create a new project.

Add Flutter Apps:

Inside your project, add a new Android app and a new iOS app.

Follow the setup instructions, including adding the package name (e.g., com.example.reelgallry) and downloading the configuration files (google-services.json for Android and GoogleService-Info.plist for iOS).

Enable Authentication:

In the Firebase Console, navigate to the Authentication section.

Go to the "Sign-in method" tab and enable the Email/Password provider.

Configure Flutter App:

The easiest way to connect your Flutter app is by using the FlutterFire CLI.

Install the CLI by running: dart pub global activate flutterfire_cli

In your project's root directory, run the configure command: flutterfire configure

This command will automatically fetch your Firebase project's configuration and generate the lib/firebase_options.dart file. You must replace the existing file with the one you generate.

🚀 How to Run the Project
Follow these steps to get the project running on your local machine.

Prerequisites
Flutter SDK (version 3.0.0 or higher)

An IDE like VS Code or Android Studio

An Android Emulator or a physical device

Steps
Clone the Repository

Bash

git clone <your-repository-url>
cd <repository-folder>
Set Up Firebase

Follow all the steps mentioned in the Backend Setup section above. This is a mandatory step.

Install Dependencies

Run the following command to fetch all the required packages.

Bash

flutter pub get
Run Code Generator

The project uses Hive, which requires generated files. Run the build_runner command to create them.

Bash

flutter pub run build_runner build --delete-conflicting-outputs
Run the App

You're all set! Run the app on your connected device or emulator.

Bash

flutter run
Enjoy your personal reel gallery! 🎉
