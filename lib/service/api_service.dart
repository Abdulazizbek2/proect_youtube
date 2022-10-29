import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:proect_youtube/model/channel_model.dart';
import 'package:proect_youtube/model/video_model.dart';
import 'package:proect_youtube/service/utils/api_key.dart';

class APIService {
  APIService._instantiate();
  static final APIService instance = APIService._instantiate();

  final String _baseUrl = 'www.googleapis.com';
  String _nextPageToken = '';

  Future<Channel> fetchChannel({required String channelId}) async {
    Map<String, String> parameters = {
      "part": 'snippet, contentDetails, statistics',
      "id": channelId,
      'key': API_KEY
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: "application/json",
    };
    //Get channel
    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body)['items'][0];
      Channel channel = Channel.fromMap(data);
      // Fetch first batch of videos from uploads playlist
      channel.videos =
          await fetchVideosFromPlaylist(playlistId: channel.uploadPlaylistId);
      return channel;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }

  Future<List<Video>> fetchVideosFromPlaylist({String? playlistId,String? pageLength='8'}) async {
    Map<String, String> parameters = {
      'part': 'snippet',
      'playlistId': playlistId!,
      'maxResults': pageLength!,
      'pageToken': _nextPageToken,
      'key': API_KEY
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };

    var response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      _nextPageToken = data['nextPageToken'] ?? "";
      List<dynamic> videosJson = data['items'];
      List<Video> videos = [];
      for (var json in videosJson) {
        videos.add(
          Video.fromMap(json['snippet']),
        );
      }
      return videos;
    } else {
      throw json.decode(response.body)['error']['message'];
    }
  }
}
