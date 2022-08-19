
class MomentModel {
  final String moment_idx;
  final String pin_idx;
  final String title;
  final String youtube_url;
  final String music;
  final String artist;
  final double distance;
  String? latitude_y;
  String? longitude_x;


  MomentModel({
    required this.moment_idx,
    required this.pin_idx,
    required this.title,
    required this.youtube_url,
    required this.music,
    required this.artist,
    required this.distance,
  });

  MomentModel.fromJson(Map<String, dynamic> json) :
    moment_idx = json['moment_idx'],
    pin_idx = json['pin_idx'],
    title = json['title'],
    youtube_url = json['youtube_url'],
    music = json['music'],
    artist = json['artist'],
    distance = json['distance'],
    latitude_y = json['pin_y'],
    longitude_x = json['pin_x'];
}
