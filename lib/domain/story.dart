class Story {
  late String _title;
  late String _user;
  late DateTime _dateTime;
  late String _youtubeLink;
  late String _img;
  late String _message;
  late String _trackName;
  late String _artist;
  // late double _lat_y;
  // late double _lng_x;

  Story(this._title, this._user, this._dateTime, this._youtubeLink, this._img,
      this._message, this._trackName, this._artist);

  factory Story.fromJson(Map<String, dynamic> parsedJson) {
    return Story(
        parsedJson["Moment_title"],
        parsedJson["Moment_user_idx"],
        DateTime.parse(parsedJson["Moment_created_at"]),
        parsedJson["Moment_youtube_url"],
        parsedJson["Moment_image_url"],
        parsedJson["Moment_description"],
        parsedJson["Moment_music"],
        parsedJson["Moment_artist"]);
  }

  String get title => _title;
  String get user => _user;
  DateTime get dateTime => _dateTime;
  String get link => _youtubeLink;
  String get img => _img;
  String get msg => _message;
  String get track => _trackName;
  String get artist => _artist;
  // double get latitude_y => _lat_y;
  // double get longitude_x => _lng_x;

}
