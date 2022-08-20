class ShowStoryArguments {
  final String firstUrl;
  final double lat_y;
  final double lng_x;
  int? pin_idx;
  int? length;

  ShowStoryArguments({
    required this.firstUrl,
    required this.lat_y,
    required this.lng_x,
    this.pin_idx,
    this.length
  });
}
