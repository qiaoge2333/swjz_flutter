import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'http.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  final String title;
  LoginPage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final TextEditingController account = new TextEditingController();
  final TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              new TextField(
                  controller: account,
                  decoration: new InputDecoration(hintText: "账号")),
              new TextField(
                keyboardType: TextInputType.number,
                controller: password,
                obscureText: true,
                decoration: new InputDecoration(hintText: "密码"),
              ),
              new RaisedButton(
                onPressed: login,
                color: Colors.blue,
                child: new Text("登陆"),
              ),
              new RaisedButton(
                  onPressed: mytest, color: Colors.red, child: new Text("测试"))
            ],
          ),
        ));
  }

  //测试
  void mytest() async {
    print("测试");
    Navigator.of(context).pop("/home");
  }

  //登陆
  void login() async {
    String accountText = account.text;
    String passwordText = password.text;
    print({'account': accountText, 'password': passwordText});
    var content = new Utf8Encoder().convert(passwordText);
    var passwordMd5 = md5.convert(content);
    FormData formData = FormData.fromMap({
      "username": accountText,
      "password": passwordMd5.toString(),
    });
    var response = await dio.post("/login", data: formData);
    print(response);
    Map<String, dynamic> info = json.decode(response.toString());
    print(info["data"]["token"]);
    dio.options.headers["token"] = info["data"]["token"];
  }
}
