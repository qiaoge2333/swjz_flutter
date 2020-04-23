import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test1/http.dart';
import 'package:test1/model/wt.dart';
import 'package:test1/wtInfo.dart';

class WorkPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new _WorkPage();
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
    var res = await dio.post("/wt/getWtListByYp", data: {
      "condition": {},
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
  }

  Widget _buildRow(Wt wt, int i) {
    return new ListTile(
        trailing: new WtInfoButton(wt),
        leading: new Text(i.toString()),
        subtitle: new Text(wt.type),
        title: new Text(
          wt.wtCode,
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
