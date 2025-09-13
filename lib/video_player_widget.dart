import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart'; // Import Hive
import 'package:video_player/video_player.dart';
import 'video_data.dart'; // Import the data model

class VideoPlayerWidget extends StatefulWidget {
  final String videoPath;
  final Function(String) onDelete;

  const VideoPlayerWidget({
    super.key,
    required this.videoPath,
    required this.onDelete,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;
  final TextEditingController _commentController = TextEditingController();
  bool _isPlaying = true;

  bool _isLiked = false;
  int _likeCount = 0;
  List<String> _comments = [];
  int _commentCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _loadVideoDataFromHive(); // Load data from Hive
  }

  void _loadVideoDataFromHive() {
    final box = Hive.box<VideoData>('video_data_box');
    final videoData = box.get(widget.videoPath);

    if (videoData != null) {
      setState(() {
        _isLiked = videoData.isLiked;
        _likeCount = videoData.likeCount;
        _comments = videoData.comments;
        _commentCount = videoData.comments.length;
      });
    }
  }

  // ... (_initializeVideoPlayer and dispose methods remain the same)

  void _initializeVideoPlayer() {
    if (widget.videoPath.startsWith('assets/')) {
      _controller = VideoPlayerController.asset(widget.videoPath)
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller.play();
            _controller.setLooping(true);
          }
        });
    } else {
      _controller = VideoPlayerController.file(File(widget.videoPath))
        ..initialize().then((_) {
          if (mounted) {
            setState(() {});
            _controller.play();
            _controller.setLooping(true);
          }
        });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    super.dispose();
  }


  Future<void> _toggleLike() async {
    final box = Hive.box<VideoData>('video_data_box');
    // Get existing data or create a new object
    VideoData videoData = box.get(widget.videoPath) ?? VideoData(comments: []);

    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likeCount++;
      } else {
        _likeCount--;
      }
    });

    // Update the object's properties
    videoData.isLiked = _isLiked;
    videoData.likeCount = _likeCount;

    // Save the updated object back to Hive
    await box.put(widget.videoPath, videoData);
  }

  Future<void> _addComment(String comment) async {
    if (comment.trim().isEmpty) return;

    final box = Hive.box<VideoData>('video_data_box');
    VideoData videoData = box.get(widget.videoPath) ?? VideoData(comments: []);

    setState(() {
      _comments.insert(0, comment);
      _commentCount = _comments.length;
    });

    // Update the comments list and save to Hive
    videoData.comments = _comments;
    await box.put(widget.videoPath, videoData);

    _commentController.clear();
    FocusScope.of(context).unfocus();
  }

  // ... (The rest of the file, including _showCommentSheet, _showDeleteConfirmation, build, _buildSideActionButtons, and _buildVideoDetails, remains unchanged)
  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _showCommentSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Text('Comments (${_commentCount})', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.grey[700]),
                  Expanded(
                    child: _comments.isEmpty
                        ? Center(
                      child: Text(
                        'No comments yet.',
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                        : ListView.builder(
                      controller: controller,
                      itemCount: _comments.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[700],
                            child: Icon(Icons.person, color: Colors.white),
                          ),
                          title: Text(_comments[index]),
                        );
                      },
                    ),
                  ),
                  Divider(height: 1, color: Colors.grey[700]),
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom,
                        left: 15,
                        right: 15,
                        top: 10
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.send, color: Colors.blueAccent),
                          onPressed: () => _addComment(_commentController.text),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation() {
    if (widget.videoPath.startsWith('assets/')) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Default videos can't be deleted."))
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Video'),
          content: const Text('Are you sure you want to delete this video?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                widget.onDelete(widget.videoPath);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _togglePlayPause,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _controller.value.isInitialized
              ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
              : const Center(child: CircularProgressIndicator(color: Colors.white)),
          Center(
            child: AnimatedOpacity(
              opacity: _isPlaying ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: Icon(
                Icons.play_arrow_rounded,
                color: Colors.white.withOpacity(0.8),
                size: 80,
              ),
            ),
          ),
          _buildSideActionButtons(),
          _buildVideoDetails(),
        ],
      ),
    );
  }

  Widget _buildSideActionButtons() {
    return Positioned(
      right: 12,
      bottom: 80,
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : Colors.white,
              size: 30,
            ),
            onPressed: _toggleLike,
          ),
          Text('$_likeCount', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.comment, color: Colors.white, size: 30),
            onPressed: _showCommentSheet,
          ),
          Text('$_commentCount', style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white, size: 30),
            onPressed: () {},
          ),
          const SizedBox(height: 15),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.white, size: 30),
            onPressed: _showDeleteConfirmation,
          ),
        ],
      ),
    );
  }

  Widget _buildVideoDetails() {
    return Positioned(
      left: 15,
      bottom: 20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '@You',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            widget.videoPath.split('/').last,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}