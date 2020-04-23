import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:test1/userinfo.dart';
import 'package:test1/work.dart';

class HomePage extends StatefulWidget {
  final String title;
  HomePage({Key key, this.title}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
    );
  }
}

class ButtonNavigationWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ButtonNavigationWidget();
}

class _ButtonNavigationWidget extends State<ButtonNavigationWidget> {
  List<Widget> pages = List<Widget>();
  final _bottomNavigationColor = Colors.blue;
  int _currentIndex = 0;

  void initState() {
    super.initState();
    pages..add(WorkPage())..add(UserInfo());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.work,
                color: _bottomNavigationColor,
              ),
              title: Text(
                '工作',
                style: TextStyle(color: _bottomNavigationColor),
              )),
          BottomNavigationBarItem(
              icon: Icon(Icons.people, color: _bottomNavigationColor),
              title:
                  Text('我的信息', style: TextStyle(color: _bottomNavigationColor)))
        ],
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
