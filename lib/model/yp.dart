class Yp {
  int id;
  String data;
  String status;
  String ypCode;
  String guicheng;
  String xmName;
  String wtCode;
  String xmCode;
  String checked;

  Yp(
      {this.id,
      this.data,
      this.status,
      this.ypCode,
      this.guicheng,
      this.xmName,
      this.wtCode,
      this.xmCode,
      this.checked});

  factory Yp.fromJson(Map<String, dynamic> json) {
    return Yp(
        id: json['id'],
        data: json['data'],
        status: json['status'],
        ypCode: json['yp_code'],
        guicheng: json['guicheng'],
        xmName: json['xm_name'],
        wtCode: json['wt_code'],
        xmCode: json['xm_code'],
        checked: json['checked']);
  }
}
