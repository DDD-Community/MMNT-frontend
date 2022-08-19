class Story {
  late String _title;
  late String _user;
  late DateTime _dateTime;
  late String _youtubeLink;
  late String _img;
  late String _message;
  late String _trackName;
  late String _artist;
  double _lat_y = 0;
  double _lng_x = 0;
  String _momentIdx = "";

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
        parsedJson["Moment_artist"]); //null
  }

  factory Story.fromJsonHistory(Map<String, dynamic> parsedJson) {
    Story _story = Story(
        parsedJson["title"],
        parsedJson["nickname"].toString().replaceAll('번째 익명이', ""),
        DateTime.parse(parsedJson["updated_at"]),
        "", //null:youtube
        parsedJson["image_url"],
        parsedJson["description"],
        parsedJson["music"],
        parsedJson["artist"]);

    _story._lat_y = double.parse(parsedJson["pin_y"]);
    _story._lng_x = double.parse(parsedJson["pin_x"]);
    _story._momentIdx = parsedJson["moment_idx"];
    return _story;
  }

  String get title => _title;
  String get user => _user;
  DateTime get dateTime => _dateTime;
  String get link => _youtubeLink;
  String get img => _img;
  String get msg => _message;
  String get track => _trackName;
  String get artist => _artist;
  double get latY => _lat_y;
  double get lngX => _lng_x;
  String get momentIdx => _momentIdx;

  void set latY(double latY) {
    _lat_y = latY;
  }

  void set lngX(double lngX) {
    _lat_y = lngX;
  }

  void set momentIdx(String momentIdx) {
    _momentIdx = momentIdx;
  }
}
