import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:proect_youtube/model/video_model.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoScreen extends StatefulWidget {
  final Video video;
  const VideoScreen({super.key, required this.video});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  YoutubePlayerController? _controller;
  @override
  void initState() {
    _controller = YoutubePlayerController(
        initialVideoId: widget.video.id!,
        flags: const YoutubePlayerFlags(
          mute: false,
          autoPlay: true,
        ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          YoutubePlayer(
            controller: _controller!,
            showVideoProgressIndicator: true,
            onReady: () {
              log("player is ready");
            },
          ),
          const SizedBox(height: 20),
          Text(
            widget.video.channelTitle!,
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              widget.video.title!,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
              overflow: TextOverflow.clip,
            ),
          ),
          const SizedBox(height: 20),
          Text(widget.video.thumbnailUrl!),
        ],
      ),
    );
  }
}
