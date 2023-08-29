import 'dart:developer';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import "dart:collection";

//throw UnimplementedError();

class QualityLinks {
  String? videoId;

  QualityLinks(this.videoId);

  getQualitiesSync(String accessToken) {
    return getQualitiesAsync(accessToken);
  }

  Future<SplayTreeMap?> getQualitiesAsync(String accessToken) async {
    try {
      final Uri? vimeoLink =
          Uri.tryParse('https://api.vimeo.com/videos/${videoId!}');
      final headers = {
        'Authorization': 'bearer $accessToken'
      };
      var response = await http.get(vimeoLink!, headers: headers);
      print(response.body);
      var jsonData =
          jsonDecode(response.body)['play']['progressive'];
      SplayTreeMap videoList = SplayTreeMap.fromIterable(
        jsonData,
        key: (item) => "${item['height']}p ${item['fps']}",
        value: (item) => item['link'],
      );
      return videoList;
    } catch (error) {
      log('=====> REQUEST ERROR: $error');
      throw error;
    }
  }
}
