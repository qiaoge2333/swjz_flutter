import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test1/http.dart';
import 'package:test1/model/wt.dart';
import 'package:test1/public.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:test1/wtInfo.dart';

class WorkPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    if (account.type == "检测") {
      return new _ComfirmYpPage();
    }
    return new _WorkPage();
  }
}

class _ComfirmYpPage extends State<WorkPage> {
  @override
  Future scanYp() async {
    scan().then((qrCode) {
      if (qrCode != "") {
        dio.post("/yp/getYpByErCode", data: {"qr_code": qrCode}).then((res) {
          print("获取的样品编号是${res.data["data"]}");
          Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
            return WtInfo(ypCode: res.data["data"]);
          }));
          print(res);
        });
      }
    });
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("扫描样品"),
      ),
      body: Center(
          child: SizedBox(
        height: 40.0,
        width: 140.0,
        child: RaisedButton(
            color: Colors.blueAccent,
            onPressed: () => scanYp(),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.camera,
                  color: Colors.white,
                ),
                Text("扫描")
              ],
            )),
      )),
    );
  }
}

class _WorkPage extends State<WorkPage> {
  final _biggerFont = const TextStyle(fontSize: 18.0);
  ScrollController _controller = new ScrollController();
  final _wts = List<Wt>();
  var _current = 1;
  var totalSize = 10000;
  String loadMoreText = "加载中";
  TextStyle loadMoreTextStyle;

  _WorkPage() {
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixel = _controller.position.pixels;
      if (maxScroll == pixel && _wts.length < totalSize) {
        setState(() {
          print("加载中");
          loadMoreText = "正在加载中...";
          loadMoreTextStyle =
              new TextStyle(color: const Color(0xFF483f6), fontSize: 14.0);
        });
        _current++;
        _getData();
      } else {
        // setState(() {
        //   print("没有数据了");
        //   loadMoreText = "没有更多数据";
        //   loadMoreTextStyle =
        //       new TextStyle(color: const Color(0xFF999999), fontSize: 14.0);
        // });
      }
    });
  }

  Future _pullToRefresh() async {
    _wts.clear();
    _current = 1;
    _getData();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("工作")),
      body: _wts.length == 0
          ? new Center(child: new CircularProgressIndicator())
          : new RefreshIndicator(
              color: const Color(0xFF483f6),
              child: ListView.builder(
                physics: new AlwaysScrollableScrollPhysics(),
                itemCount: _wts.length + 1,
                itemBuilder: (context, i) {
                  if (i == _wts.length) {
                    return _buildProcessMoreIndicator();
                  } else {
                    return _buildRow(_wts[i], i + 1);
                    // return renderRow(i, context);
                  }
                },
                controller: _controller,
              ),
              onRefresh: _pullToRefresh),
    );
  }

  void initState() {
    super.initState();
    _getData();
  }

  renderRow(i, context) {
    return new Text(_wts[i].wtCode);
  }

  Widget _buildProcessMoreIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(15.0),
      child: new Center(
        child: new Text(loadMoreText, style: loadMoreTextStyle),
      ),
    );
  }

  void _getData() async {
    setState(() {
      _wts.clear();
    });
    try {
      var res = await dio.post("/wt/getWtListByYp", data: {
        "condition": {"w.status": "提交", "s.status": "提交"},
        "page": {
          "limit": 15,
          "current": _current,
        }
      });
      Map<String, dynamic> resData = json.decode(res.toString());
      List rows = resData["data"]["rows"];
      print(rows);
      List<Wt> wts = rows.map((m) => new Wt.fromJson(m)).toList();
      setState(() {
        _wts.addAll(wts);
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "请求数据失败");
      setState(() {
        _wts.clear();
      });
      print(e);
    }
  }

  void toWtInfo(Wt wt) {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      return WtInfo(ypCode: wt.ypCode);
    })).then((result) {
      if (result == true) {
        _getData();
      }
    });
  }

  Widget buildWtinfo(Wt wt) {
    return new RaisedButton(
      onPressed: () => toWtInfo(wt),
      child: new Text("工作详情"),
    );
  }

  Widget _buildRow(Wt wt, int i) {
    return new ListTile(
        trailing: new WtInfoButton(wt),
        leading: new Text(i.toString()),
        subtitle: new Text(wt.wtCode),
        title: new Text(
          wt.xmName,
          style: _biggerFont,
        ));
  }
}

class WtInfoButton extends StatelessWidget {
  final Wt wt;

  WtInfoButton(this.wt);

  @override
  Widget build(BuildContext context) {
    Widget buildWtInfo(BuildContext context) {
      return WtInfo(ypCode: wt.ypCode);
    }

    void wtInfo() {
      Navigator.of(context).push(new MaterialPageRoute(builder: buildWtInfo));
    }

    return new RaisedButton(
      onPressed: wtInfo,
      child: new Text("工作详情"),
    );
  }
}
