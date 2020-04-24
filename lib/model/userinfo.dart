class Account {
  bool loaded;
  int id;
  String etpName;
  int etpId;
  int userId;
  String name;
  String type;
  Account(
      {this.name,
      this.loaded,
      this.id,
      this.etpName,
      this.etpId,
      this.type,
      this.userId});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
        etpName: json["etpName"], type: json["type"], name: json["userName"]);
  }
}

class UserInfo {
  int id;
  String name;
  String email;
  String phone;
  String address;
  String image;
  String idCard;
  int age;
  String sex;

  UserInfo(
      {this.id,
      this.name,
      this.email,
      this.address,
      this.age,
      this.idCard,
      this.image,
      this.phone,
      this.sex});
  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      address: json["address"],
      id: json["id"],
      age: json["age"],
      phone: json["phone"],
      name: json["name"],
      email: json["email"],
      image: json["image"],
      idCard: json["id_card"],
      sex: json["sex"],
    );
  }
}
