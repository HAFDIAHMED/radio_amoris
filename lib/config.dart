// Generated by https://quicktype.io

import 'dart:io' show Platform;

class Config {
  List<Channel> channels;

  Config({
    this.channels,
  }) {
    channels = new List<Channel>();
  }

  factory Config.fromJson(Map<String, dynamic> json) {
    var result = new Config();
    for (var fragment in json['channels']) {
      result.channels.add(Channel.fromJson(fragment));
    }
    return result;
  }
}

class Channel {
  String name;
  String listenurl;
  String metadata;

  Channel({
    this.name,
    this.listenurl,
    this.metadata,
  });

  factory Channel.fromJson(Map<String, dynamic> json) {
    var mediaUrl = json['listenurl'];
    if (Platform.isAndroid) {
      mediaUrl = mediaUrl.replaceAll('https://', 'http://');
    }
    return new Channel(
      name: json['name'],
      listenurl: mediaUrl,
      metadata: json['metadata'],
    );
  }
}
