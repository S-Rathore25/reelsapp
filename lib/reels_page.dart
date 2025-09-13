import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth को import करें
import 'my_videos_page.dart';
import 'video_player_widget.dart';
import 'video_data.dart';

class ReelsPage extends StatefulWidget {
  const ReelsPage({super.key});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final List<String> _videoPaths = [
    'assets/videos/video1.mp4',
    'assets/videos/video2.mp4',
    'assets/videos/video3.mp4',
  ];
  final ImagePicker _picker = ImagePicker();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _loadVideos();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadVideos() async {
    final box = Hive.box<String>('user_videos_box');
    final savedVideos = box.values.toList();
    if (mounted) {
      setState(() {
        for (var video in savedVideos) {
          if (!_videoPaths.contains(video)) {
            _videoPaths.add(video);
          }
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    var status = await Permission.videos.request();
    if (status.isDenied) {
      status = await Permission.storage.request();
    }

    if (status.isGranted) {
      final XFile? file = await _picker.pickVideo(source: ImageSource.gallery);
      if (file != null && mounted) {
        final box = Hive.box<String>('user_videos_box');
        await box.add(file.path);
        setState(() {
          _videoPaths.add(file.path);
        });
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permission is required to pick videos.')));
      }
    }
  }

  Future<void> _deleteVideo(String pathToDelete) async {
    final dataBox = Hive.box<VideoData>('video_data_box');
    await dataBox.delete(pathToDelete);

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
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: _videoPaths.length,
            itemBuilder: (context, index) {
              return VideoPlayerWidget(
                key: ValueKey(_videoPaths[index]),
                videoPath: _videoPaths[index],
                onDelete: _deleteVideo,
              );
            },
          ),
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
          Positioned(
            top: MediaQuery.of(context).padding.top + 5.0,
            right: 10,
            child: PopupMenuButton<String>(
              onSelected: (value) async { // इसे async बनाएं
                if (value == 'all_videos') {
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
                // ## SIGN OUT LOGIC YAHAN ADD KIYA GAYA HAI ##
                if (value == 'sign_out') {
                  await FirebaseAuth.instance.signOut();
                  // AuthGate apne aap Login screen par bhej dega
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'all_videos',
                  child: Text('All Videos'),
                ),
                // ## SIGN OUT KA OPTION YAHAN ADD KIYA GAYA HAI ##
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
      floatingActionButton: FloatingActionButton(
        onPressed: _pickVideo,
        child: const Icon(Icons.add),
      ),
    );
  }
}