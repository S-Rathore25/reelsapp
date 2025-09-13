import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class MyVideosPage extends StatelessWidget {
  // List of paths for all videos (both assets and from gallery).
  final List<String> videoPaths;
  // The PageController from the ReelsPage to control the video position.
  final PageController pageController;

  const MyVideosPage({
    super.key,
    required this.videoPaths,
    required this.pageController,
  });

  // A function to generate a thumbnail from a given video path.
  Future<Uint8List?> _generateThumbnail(String videoPath) async {
    try {
      String pathForThumbnail = videoPath;

      // before a thumbnail can be generated.
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

      // Generate thumbnail data from the video file path.
      final thumbnail = await VideoThumbnail.thumbnailData(
        video: pathForThumbnail,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 150,
        quality: 25,
      );
      return thumbnail;
    } catch (e) {
      // Print the error for debugging purposes.
      debugPrint("Thumbnail generation error for path '$videoPath': $e");
      // Return null if an error occurs.
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
        // Configure the grid layout with 3 columns.
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: videoPaths.length,
        itemBuilder: (context, index) {
          final videoPath = videoPaths[index];
          // GestureDetector to handle taps on thumbnails.
          return GestureDetector(
            onTap: () {
              // When a thumbnail is tapped, jump to the corresponding video in the ReelsPage.
              pageController.jumpToPage(index);
              // Go back to the ReelsPage.
              Navigator.of(context).pop();
            },
            child: Card(
              elevation: 2.0,
              clipBehavior: Clip.antiAlias,
              color: Colors.grey[850],
              // Use FutureBuilder to display the thumbnail once it's generated.
              child: FutureBuilder<Uint8List?>(
                future: _generateThumbnail(videoPath),
                builder: (context, snapshot) {
                  // Show a loading indicator while the thumbnail is being generated.
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(strokeWidth: 2.0));
                  }
                  // If thumbnail data is available, display it.
                  if (snapshot.data != null) {
                    return Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        ),
                        // Overlay a play icon on the thumbnail.
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
                  // If data is null (due to an error), show a 'video off' icon.
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