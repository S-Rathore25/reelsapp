import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyVideosPage extends StatelessWidget {
  final List<String> videoPaths;
  final PageController pageController;

  const MyVideosPage({
    super.key,
    required this.videoPaths,
    required this.pageController,
  });

  // Video path se thumbnail banane ka function
  Future<Uint8List?> _generateThumbnail(String videoPath) async {
    try {
      String pathForThumbnail = videoPath;

      if (videoPath.startsWith('assets/')) {
        final byteData = await rootBundle.load(videoPath);
        final tempDir = await getTemporaryDirectory();
        final tempFile = File('${tempDir.path}/${videoPath.split('/').last}');
        await tempFile.writeAsBytes(byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ));
        pathForThumbnail = tempFile.path;
      }

      final thumbnail = await VideoThumbnail.thumbnailData(
        video: pathForThumbnail,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 150,
        quality: 25,
      );
      return thumbnail;
    } catch (e) {
      // Yahan error ko print karein taaki hum dekh sakein ki kya galat hai
      debugPrint("Thumbnail generation error for path '$videoPath': $e");
      // Error hone par null return karein
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My App Videos'),
        centerTitle: true,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(4.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          final videoPath = videoPaths[index];
          return GestureDetector(
            onTap: () {
              pageController.jumpToPage(index);
              Navigator.of(context).pop();
            },
            child: Card(
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              color: Colors.grey[850],
              child: FutureBuilder<Uint8List?>(
                future: _generateThumbnail(videoPath),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                  }
                  // Ab hum null check kar rahe hain, error check nahi
                  if (snapshot.data != null) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_fill,
                            color: Colors.white70,
                            size: 40,
                          ),
                        ),
                      ],
                    );
                  }
                  // Agar data null hai (error ki wajah se), to ye icon dikhega
                  return const Center(child: Icon(Icons.videocam_off, color: Colors.grey));
                },
              ),
            ),
          );
        },
      ),
    );
  }
}