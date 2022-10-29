import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:proect_youtube/model/channel_model.dart';
import 'package:proect_youtube/model/video_model.dart';
import 'package:proect_youtube/pages/video_screen.dart';
import 'package:proect_youtube/service/api_service.dart';

class HomaPage extends StatefulWidget {
  const HomaPage({super.key});

  @override
  State<HomaPage> createState() => _HomaPageState();
}

class _HomaPageState extends State<HomaPage> {
  Channel? _channel;
  bool _isLoading = false;

  int? _countVideo=6;

  @override
  void initState() {
    super.initState();
    _initChannel();
  }

  _initChannel() async {
    Channel channel = await APIService.instance
        .fetchChannel(channelId: 'UCPeTYmW9zPwOpCOwjYAGdDw');
    setState(() {
      _channel = channel;
    });
  }

  _loadMoreVideos() async {
    _isLoading = true;
    List<Video> moreVideos = await APIService.instance
        .fetchVideosFromPlaylist(playlistId: _channel!.uploadPlaylistId);
    List<Video> allVideos = _channel!.videos!..addAll(moreVideos);
    setState(() {
      _channel!.videos = allVideos;
    });
    _isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text("Subyektiv")),
        // ignore: unnecessary_null_comparison
        body: _channel != null 
            ? NotificationListener<ScrollNotification>(
                onNotification: (ScrollNotification scrollDetails) {
                  if (!_isLoading &&
                      _channel!.videos!.length >_countVideo!
                          &&
                      scrollDetails.metrics.pixels ==
                          scrollDetails.metrics.maxScrollExtent) {
                            _countVideo=_countVideo!+6;
                            log(_countVideo!.toString());
                            setState(() {});
                    _loadMoreVideos();
                  }
                  return false;
                },
                child: ListView.builder(
                  itemCount: 1 + _channel!.videos!.length,
                  itemBuilder: ((context, index) {
                    if (index == 0) {
                      return _buildProfileInfo();
                    }
                    Video video = _channel!.videos![index - 1];
                    return _buildVideo(video);
                  }),
                ))
            : Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor),
                ),
              ));
  }

  _buildProfileInfo() {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      height: 100.0,
      decoration: const BoxDecoration(color: Colors.white, boxShadow: [
        BoxShadow(color: Colors.black12, offset: Offset(0, 1), blurRadius: 6.0)
      ]),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            radius: 35.0,
            backgroundImage: NetworkImage(_channel!.profilePictureUrl!),
          ),
          const SizedBox(
            width: 12.0,
          ),
          Expanded(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _channel!.title!,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                '${_channel!.videoCount?? 0} videos',
                style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              )
            ],
          ))
        ],
      ),
    );
  }

  _buildVideo(Video video) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => VideoScreen(video: video))),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
        padding: const EdgeInsets.all(10.0),
        height: 140.0,
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(
            color: Colors.black12,
            offset: Offset(0, 1),
            blurRadius: 6.0,
          )
        ]),
        child: Row(
          children: [
            Image(
              width: 150,
              image: NetworkImage(video.thumbnailUrl!),
            ),
            const SizedBox(
              width: 10.0,
            ),
            Expanded(
              child: Text(
                video.title!,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18.0,
                    overflow: TextOverflow.clip),
              ),
            )
          ],
        ),
      ),
    );
  }
}
