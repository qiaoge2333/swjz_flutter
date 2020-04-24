import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:test1/loadingDialog.dart';
import 'package:test1/model/userinfo.dart';
import 'package:test1/public.dart';
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
  final TextEditingController userName = new TextEditingController();
  final TextEditingController password = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Container(
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new AssetImage("asset/login.png"),
                    fit: BoxFit.fill)),
            child: Align(
              child: Container(
                decoration: new BoxDecoration(
                    color: Color(0xAA86b0ed),
                    borderRadius: BorderRadius.all(Radius.circular(45.0))),
                padding: EdgeInsets.all(20.0),
                child: SizedBox(
                    height: 150,
                    child: Column(
                      children: <Widget>[
                        new TextField(
                            controller: userName,
                            decoration: new InputDecoration(hintText: "账号")),
                        new TextField(
                          keyboardType: TextInputType.number,
                          controller: password,
                          obscureText: true,
                          decoration: new InputDecoration(hintText: "密码"),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            RaisedButton(
                              onPressed: login,
                              color: Colors.blue,
                              child: new Text("登陆"),
                            ),
                            RaisedButton(
                              onPressed: login,
                              color: Colors.blue,
                              child: new Text("重置"),
                            ),
                          ],
                        )
                      ],
                    )),
              ),
            )));
  }

  //登陆
  void login() async {
    showDialog(
        context: context,
        builder: (context) {
          return LoadingDialog(text: "登陆中");
        });
    String userNameText = userName.text;
    String passwordText = password.text;
    print({'account': userNameText, 'password': passwordText});
    var content = new Utf8Encoder().convert(passwordText);
    var passwordMd5 = md5.convert(content);
    FormData formData = FormData.fromMap({
      "username": userNameText,
      "password": passwordMd5.toString(),
    });
    var res = await dio.post("/login", data: formData);
    if (res.data["msg"] == "登陆成功") {
      //退出load
      Navigator.of(context).pop();
      //为请求头添加令牌
      dio.options.headers["token"] = res.data["data"]["token"];
      //将信息添加到account中
      account = new Account.fromJson(res.data["data"]["userinfo"]);
      Navigator.of(context).pop(true);
      setState(() {
        account.loaded = true;
      });
    }
  }
}
