class YpImage {
  int id;
  String path;
  String ypCode;
  String type;

  YpImage({this.id, this.path, this.ypCode, this.type});

  factory YpImage.fromJson(Map<String, dynamic> json) {
    return YpImage(
      id: json['id'],
      path: json['path'],
      ypCode: json['yp_code'],
      type: json['type'],
    );
  }
}
