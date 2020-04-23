class YpImage {
  int id;
  String path;
  String ypCode;
  String type;
  int idx;

  YpImage({this.id, this.path, this.ypCode, this.type, this.idx});

  factory YpImage.fromJson(Map<String, dynamic> json) {
    return YpImage(
        id: json['id'],
        path: json['path'],
        ypCode: json['yp_code'],
        type: json['type'],
        idx: json['idx']);
  }
}
