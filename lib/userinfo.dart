import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test1/http.dart';
import 'package:test1/loadingDialog.dart';
import 'package:test1/model/userinfo.dart';
import 'package:test1/public.dart';

class UserInfoPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _UserInfoPage();
}

class _UserInfoPage extends State<UserInfoPage> {
  UserInfo userinfo;
  void loginOut() {
    dio.options.headers.remove("token");
    setState(() {
      account = new Account(loaded: false);
    });
  }

  void initState() {
    super.initState();
    getUserInfo();
  }

  Future getUserInfo() async {
    userinfo = null;
    //弹出加载框
    dio
        .get(
      "/user/getUserInfo",
    )
        .then((res) {
      setState(() {
        userinfo = new UserInfo.fromJson(res.data["data"]);
      });
      print(res);
    });
  }

  static String getString(dynamic value) {
    return value == null ? "" : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("工作")),
        body: Container(
          child: Column(
            children: <Widget>[
              ListTile(
                title: Text("名称"),
                trailing: Text(getString(userinfo.name)),
              ),
              ListTile(
                title: Text("手机号"),
                trailing: Text(getString(userinfo.phone)),
              ),
              ListTile(
                title: Text("邮箱"),
                trailing: Text(getString(userinfo.email)),
              ),
              ListTile(
                title: Text("联系地址"),
                trailing: Text(getString(userinfo.address)),
              ),
              ListTile(
                title: Text("年龄"),
                trailing: Text(getString(userinfo.age)),
              ),
              ListTile(
                title: Text("性别"),
                trailing: Text(getString(userinfo.sex)),
              ),
              RaisedButton(onPressed: loginOut, child: Text("登出")),
            ],
          ),
        ));
  }
}
