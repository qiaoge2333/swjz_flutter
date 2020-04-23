class Template {
  int id;
  String data;
  String status;
  String xmCode;
  String guicheng;

  Template({this.id, this.data, this.status, this.xmCode, this.guicheng});

  factory Template.fromJson(Map<String, dynamic> json) {
    return Template(
        id: json['id'],
        data: json['data'],
        status: json['status'],
        xmCode: json['xm_code'],
        guicheng: json['guicheng']);
  }
}
