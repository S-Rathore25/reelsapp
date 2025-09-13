import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'my_videos_page.dart';
import 'video_player_widget.dart';
import 'video_data.dart';

// The main screen for displaying vertical scrolling video reels.
class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  // List of initial video paths from assets.
  final List<String> _videoPaths = [
    'assets/videos/video1.mp4',
    'assets/videos/video2.mp4',
    'assets/videos/video3.mp4',
  ];
  // Instance of ImagePicker to pick videos from the gallery.
  final ImagePicker _picker = ImagePicker();
  // Controller for the PageView to manage video scrolling.
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // Load videos from local storage when the widget is initialized.
    _loadVideos();
  }

  @override
  void dispose() {
    // Dispose the PageController to free up resources.
    _pageController.dispose();
    super.dispose();
  }

  // Loads video paths stored locally in the Hive box.
  Future<void> _loadVideos() async {
    final box = Hive.box<String>('user_videos_box');
    final savedVideos = box.values.toList();
    if (mounted) {
      setState(() {
        // Add saved videos to the list if they are not already present.
        for (var video in savedVideos) {
          if (!_videoPaths.contains(video)) {
            _videoPaths.add(video);
          }
        }
      });
    }
  }

  // Picks a video from the device gallery.
  Future<void> _pickVideo() async {
    // Request permission to access videos/storage.
    var status = await Permission.videos.request();
    if (status.isDenied) {
      // If video permission is denied, request general storage permission.
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      // If permission is granted, pick a video.
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null && mounted) {
        // Save the picked video's path to the Hive box.
        final box = Hive.box<String>('user_videos_box');
        await box.add(file.path);
        // Add the new video path to the state to update the UI.
        setState(() {
          _videoPaths.add(file.path);
        });
      }
    } else {
      // If permission is not granted, show a snackbar message.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission is required to pick videos.')));
      }
    }
  }

  // Deletes a video from the app and local storage.
  Future<void> _deleteVideo(String pathToDelete) async {
    // Delete associated data like likes and comments from the data box.
    final dataBox = Hive.box<VideoData>('video_data_box');
    await dataBox.delete(pathToDelete);

    // Find and delete the video path from the videos box.
    final videosBox = Hive.box<String>('user_videos_box');
    final Map<dynamic, String> map = videosBox.toMap();
    dynamic keyToDelete;
    map.forEach((key, value) {
      if (value == pathToDelete) {
        keyToDelete = key;
      }
    });
    if (keyToDelete != null) {
      await videosBox.delete(keyToDelete);
    }

    // Remove the video path from the state and update the UI.
    if (mounted) {
      setState(() {
        _videoPaths.remove(pathToDelete);
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Video deleted successfully.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView for vertical scrolling of videos.
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videoPaths.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                // Use ValueKey to ensure the widget rebuilds when the path changes.
                key: ValueKey(_videoPaths[index]),
                videoPath: _videoPaths[index],
                onDelete: _deleteVideo,
              );
            },
          ),
          // Centered title text at the top of the screen.
          Positioned(
            top: MediaQuery.of(context).padding.top + 15.0,
            left: 0,
            right: 0,
            child: const Text(
              'Flutter Reels',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                shadows: <Shadow>[
                  Shadow(
                    offset: Offset(1.0, 1.0),
                    blurRadius: 3.0,
                    color: Color.fromARGB(150, 0, 0, 0),
                  ),
                ],
              ),
            ),
          ),
          // Popup menu button for "All Videos" and "Sign Out".
          Positioned(
            top: MediaQuery.of(context).padding.top + 5.0,
            right: 10,
            child: PopupMenuButton<String>(
              onSelected: (value) async { // Make the handler async
                if (value == 'all_videos') {
                  // Navigate to the MyVideosPage.
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MyVideosPage(
                        videoPaths: _videoPaths,
                        pageController: _pageController,
                      ),
                    ),
                  );
                }

                if (value == 'sign_out') {
                  await FirebaseAuth.instance.signOut();
                  // AuthGate will automatically handle navigation to the LoginScreen.
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'all_videos',
                  child: Text('All Videos'),
                ),
                const PopupMenuItem<String>(
                  value: 'sign_out',
                  child: Text('Sign Out'),
                ),
              ],
              icon: const Icon(Icons.more_vert, color: Colors.white),
            ),
          ),
        ],
      ),
      // Floating action button to pick new videos.
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: const Icon(Icons.add),
      ),
    );
  }
}