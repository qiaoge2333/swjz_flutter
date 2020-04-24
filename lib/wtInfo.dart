import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test1/http.dart';
import 'package:test1/imageUpload.dart';
import 'package:test1/imageView.dart';
import 'package:test1/model/template.dart';
import 'package:test1/public.dart';

import 'model/wt.dart';
import 'model/yp.dart';
import 'model/ypImage.dart';

class WtInfo extends StatefulWidget {
  final String ypCode;
  WtInfo({Key key, this.ypCode}) : super(key: key);
  @override
  State<StatefulWidget> createState() => new _WtInfo(ypCode: ypCode);
}

class _WtInfo extends State<WtInfo> {
  List<Widget> pages = List<Widget>();
  int _currentIndex = 0;
  final String ypCode;
  Wt wt;
  Yp yp;

  Template template;
  List<Uint8List> assets = new List();

  void initState() {
    super.initState();
    print("样品编号：$ypCode");
    getData(ypCode);
  }

  _WtInfo({Key key, this.ypCode});
  getData(String ypCode) async {
    await dio.get("/wt/getWtInfo?yp_code=" + ypCode).then((res) {
      wt = Wt.fromJson(res.data["data"]["wt"]);
      yp = Yp.fromJson(res.data["data"]["yp_data"]);
      template = Template.fromJson(res.data["data"]["template"]);
      setState(() {
        pages
          ..add(GcInfo(wt: wt))
          ..add(YpInfo(
              yp: yp,
              template: template,
              status: res.data["data"]["yp"]["status"]))
          ..add(YpPicture(ypCode: yp.ypCode));
      });
      //获取样品图片信息
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("委托详情:")),
        bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                  ),
                  title: Text("工程信息")),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.info,
                    color: Colors.blue,
                  ),
                  title: Text("样品信息")),
              BottomNavigationBarItem(
                  icon: Icon(
                    Icons.insert_photo,
                    color: Colors.blue,
                  ),
                  title: Text("样品图片")),
            ]),
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ));
  }
}

class YpInfo extends StatefulWidget {
  final Yp yp;
  final String status;
  final Template template;
  YpInfo({Key key, this.yp, this.status, this.template}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      _YpInfo(yp: yp, template: template, status: status);
}

class KeyValue {
  String key;
  String value;
  KeyValue({this.key, this.value});
}

class _YpInfo extends State<YpInfo> {
  final Yp yp;
  final Template template;
  final String status;
  Map<String, dynamic> jsonYp;
  Map<String, dynamic> jsonTemplate;
  List<KeyValue> forms = new List();

  _YpInfo({this.yp, this.template, this.status});
  static String getString(String value) {
    String s = value;
    if (s == "null") {
      return "";
    }
    if (s.startsWith("[")) {
      s = s.substring(1, s.length - 1);
      List<String> ss = s.split(",");
      s = ss.join("\n");
    }
    return s;
  }

  Future confirmYp() async {
    final action = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(children: <Widget>[
                Icon(
                  Icons.chat,
                  color: Colors.green,
                  size: 40,
                ),
                Text("确认样品")
              ]),
              content: Text("请仔细检测该样品是否是正确样品!"),
              actions: <Widget>[
                FlatButton(
                    child: Text("不通过"),
                    onPressed: () => Navigator.pop(context, "不通过")),
                FlatButton(
                  child: Text("通过"),
                  onPressed: () => Navigator.pop(context, "通过"),
                )
              ],
            ));
    try {
      dio.post("/yp/comfirmYp", data: {
        "yp_code": yp.ypCode,
        "status": action,
      }).then((res) {
        if (res.data["msg"] == "确认成功") {
          Navigator.pop(context);
        }
      });
    } catch (e) {
      print("确认样品发送错误: $e");
    }
  }

  Future scanYp() async {
    final action = await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Row(children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.yellow,
                  size: 40,
                ),
                Text("注意")
              ]),
              content: Text("确认扫描样品二维码吗?\n扫描后该样品将确认收样!"),
              actions: <Widget>[
                FlatButton(
                    child: Text("取消"),
                    onPressed: () => Navigator.pop(context, "取消")),
                FlatButton(
                  child: Text("确认"),
                  onPressed: () => Navigator.pop(context, "确认"),
                )
              ],
            ));
    if (action == "确认") {
      scan().then((qrCode) {
        try {
          dio.post("/yp/comfirmYp",
              data: {"yp_code": yp.ypCode, "status": "确认"}).then((res) {
            Fluttertoast.showToast(msg: res.data["msg"]);
            if (res.data["msg"] == "确认成功") {
              Navigator.pop(context, true);
            }
          });
        } catch (e) {
          Fluttertoast.showToast(msg: "确认样品失败，发生未知错误：$e");
        }
      });
    }
  }

  Widget buildBottomBtns() {
    if (account.type == "取样") {
      return Center(
        child: RaisedButton(
          onPressed: () => scanYp(),
          child: Text("扫描样品"),
        ),
      );
    } else if (account.type == "检测") {
      switch (status) {
        case "确认":
          return Center(
            child: RaisedButton(
              color: Colors.blue,
              onPressed: () => confirmYp(),
              child: Text("确认样品"),
            ),
          );
          break;
        case "通过":
        case "不通过":
          return Center(child: Text("已确认"));
          break;
      }
    }
    return Divider();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      jsonYp = json.decode(yp.data);
      jsonTemplate = json.decode(template.data);
    });
    List<dynamic> forms1 = jsonTemplate["forms"];

    forms.clear();
    List<KeyValue> v1 = new List();
    forms1.forEach((v) {
      List<dynamic> cell = v;
      for (var i = 1; i < cell.length; i += 2) {
        var key = cell[i - 1];
        var value = jsonYp[cell[i]["name"]].toString();
        if (cell[i]["name"] == "yp_code") {
          value = yp.ypCode;
        }
        v1.add(KeyValue(key: key, value: value));
      }
    });
    setState(() {
      forms.addAll(v1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: <Widget>[
          Table(
            columnWidths: const {
              0: FixedColumnWidth(100.0),
            },
            border: TableBorder.all(
              color: Colors.black,
              width: 1.0,
              style: BorderStyle.solid,
            ),
            children: List.generate(forms.length, (index) {
              return TableRow(children: [
                SizedBox(child: Text(forms[index].key), height: 40.0),
                Text(getString(forms[index].value))
              ]);
            }),
          ),
          buildBottomBtns()
        ],
      ),
    ));
  }
}

class YpPicture extends StatefulWidget {
  final String ypCode;

  YpPicture({Key key, this.ypCode}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _YpPicture(ypCode: ypCode);
}

class _YpPicture extends State<YpPicture> {
  final String ypCode;
  bool _loadFinish = false;
  List<Uint8List> qyPictures = new List();
  List<Uint8List> jzPictures = new List();
  _YpPicture({this.ypCode});

  void initState() {
    super.initState();
    if (qyPictures.length == 0 || jzPictures.length == 0) {
      loadImage();
    }
  }

  loadImage() async {
    qyPictures.clear();
    jzPictures.clear();
    await dio.get("/image/getYpImageInfo",
        queryParameters: {"yp_code": ypCode}).then((res) async {
      Map<String, dynamic> resData = json.decode(res.toString());
      List images = resData["data"]["images"];
      List<YpImage> ypImages =
          images.map((m) => new YpImage.fromJson(m)).toList();
      for (var i = 0; i < ypImages.length; i++) {
        await dio
            .post("/image/getImage",
                queryParameters: {
                  "path": ypImages[i].path,
                },
                options: Options(responseType: ResponseType.bytes))
            .then((res) {
          setState(() {
            if (ypImages[i].type == "见证") {
              setState(() {
                jzPictures.add(res.data);
              });
            } else {
              setState(() {
                qyPictures.add(res.data);
              });
            }
          });
        });
      }
      setState(() {
        _loadFinish = true;
      });
    });
  }

  void uploadImage(String type, int num) {
    Navigator.of(context)
        .push(new MaterialPageRoute(
            builder: (context) => ImageUpload(
                  type: type,
                  currentImages: num,
                  ypCode: ypCode,
                )))
        .then((data) {
      print("返回数据为： $data");
      if (data == true) {
        //重新加载图片
        loadImage();
      }
    });
  }

  void uploadQyImage() {
    uploadImage("取样", qyPictures.length);
  }

  void uploadJzImage() {
    print("上传见证照片");
    print("见证照片数目 ${jzPictures.length}");
    uploadImage("见证", jzPictures.length);
  }

  Widget buildImageUploadBtns(String type) {
    print(account.type);
    if (account.type == type) {
      return Center(
          child: Column(
        children: <Widget>[
          ListTile(
              title: Text(type + "照片",
                  style: new TextStyle(fontWeight: FontWeight.w500)),
              subtitle: _loadFinish
                  ? RaisedButton(
                      onPressed: () {
                        if (type == "见证") {
                          return jzPictures.length < 6 ? uploadJzImage() : null;
                        }
                        return qyPictures.length < 6 ? uploadQyImage() : null;
                      },
                      child: Text("上传$type照片"),
                    )
                  : null),
        ],
      ));
    }
    return ListTile(
      title: Text(
        type + "照片",
        style: new TextStyle(fontWeight: FontWeight.w400),
      ),
    );
  }

  void showImage(Uint8List asset) {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ImageView(
        asset: asset,
      );
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        Center(child: buildImageUploadBtns("见证")),
        Expanded(
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(jzPictures.length, (index) {
              var asset = jzPictures[index];
              return InkWell(
                onTap: () => showImage(asset),
                child: Image.memory(asset),
              );
            }),
          ),
        ),
        Center(
          child: buildImageUploadBtns("取样"),
        ),
        Expanded(
          child: GridView.count(
              crossAxisCount: 3,
              children: List.generate(qyPictures.length, (index) {
                var asset = qyPictures[index];
                return InkWell(
                  onTap: () => showImage(asset),
                  child: Image.memory(asset),
                );
              })),
        )
      ]),
    );
  }
}

class GcInfo extends StatelessWidget {
  final Wt wt;

  GcInfo({Key key, this.wt}) : super(key: key);
  static String getString(String value) {
    return value == null ? "" : value;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Table(
          columnWidths: const {
            0: FixedColumnWidth(100.0),
          },
          border: TableBorder.all(
            color: Colors.black,
            width: 1.0,
            style: BorderStyle.solid,
          ),
          children: [
            TableRow(children: [
              SizedBox(
                height: 40.0,
                child: Text("电子委托编号"),
              ),
              Text(getString(wt.wtCode))
            ]),
            TableRow(children: [
              SizedBox(
                height: 40.0,
                child: Text("委托日期"),
              ),
              Text(getString(wt.wtDate))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("施工过程")),
              Text(getString(wt.gcName))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("检测类别")),
              Text(getString(wt.type))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("委托单位")),
              Text(getString(wt.sgUnitName))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("委托人/手机号")),
              Text(getString(wt.wtPeopleName) +
                  " " +
                  getString(wt.wtPeoplePhone)),
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("检测单位")),
              Text(getString(wt.wtUnitName))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("取样人/手机号")),
              Text(getString(wt.qyPeopleName) +
                  " " +
                  getString(wt.qyPeoplePhone)),
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("监理单位")),
              Text(getString(wt.jlUnitName))
            ]),
            TableRow(children: [
              SizedBox(height: 40.0, child: Text("见证人/手机号")),
              Text(getString(wt.jzPeopleName) +
                  " " +
                  getString(wt.jzPeoplePhone)),
            ]),
            TableRow(children: [
              SizedBox(height: 120.0, child: Text("备注")),
              Text(getString(wt.beizhu))
            ]),
          ],
        ),
      ),
    );
  }
}
