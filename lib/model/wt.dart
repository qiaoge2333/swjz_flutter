class Wt {
  int id;
  int sgUnit;
  String sgUnitName;
  String wtDate;
  int gcId;
  String gcName;
  String wtCode;
  int wtUnit;
  int jlUnit;
  String jlUnitName;
  String wtUnitName;
  int wtPeopleId;
  String wtPeopleName;
  String wtPeoplePhone;
  int qyPeopleId;
  String qyPeopleName;
  String qyPeoplePhone;
  int jzPeopleId;
  String jzPeopleName;
  String jzPeoplePhone;
  String type;
  String beizhu;
  String status;
  String ypCode;
  String xmName;
  String xmCode;

  Wt(
      {this.id,
      this.sgUnit,
      this.sgUnitName,
      this.gcId,
      this.wtDate,
      this.gcName,
      this.wtCode,
      this.ypCode,
      this.xmName,
      this.xmCode,
      this.wtUnit,
      this.jlUnit,
      this.jlUnitName,
      this.wtUnitName,
      this.wtPeopleId,
      this.wtPeopleName,
      this.wtPeoplePhone,
      this.qyPeopleId,
      this.qyPeopleName,
      this.qyPeoplePhone,
      this.jzPeopleId,
      this.jzPeopleName,
      this.jzPeoplePhone,
      this.type,
      this.beizhu,
      this.status});

  factory Wt.fromJson(Map<String, dynamic> json) {
    return Wt(
        id: json['id'],
        sgUnit: json['sg_unit'],
        sgUnitName: json['sg_unit_name'],
        gcId: json['gc_id'],
        wtDate: json['wt_date'],
        gcName: json['gc_name'],
        wtCode: json['wt_code'],
        wtUnit: json['wt_unit'],
        jlUnit: json['jl_unit'],
        ypCode: json["yp_code"],
        xmName: json["xm_name"],
        xmCode: json["xm_code"],
        jlUnitName: json['jl_unit_name'],
        wtUnitName: json['wt_unit_name'],
        wtPeopleId: json['wt_people_id'],
        wtPeopleName: json['wt_people_name'],
        wtPeoplePhone: json['wt_people_phone'],
        qyPeopleId: json['qy_people_id'],
        qyPeopleName: json['qy_people_name'],
        qyPeoplePhone: json['qy_people_phone'],
        jzPeopleId: json['jz_people_id'],
        jzPeopleName: json['jz_people_name'],
        jzPeoplePhone: json['jz_people_phone'],
        type: json['type'],
        beizhu: json['beizhu'],
        status: json['status']);
  }
}
