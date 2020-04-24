import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  final Uint8List asset;
  ImageView({Key key, this.asset}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _ImageView(asset: asset);
  }
}

class _ImageView extends State<ImageView> {
  final Uint8List asset;

  _ImageView({this.asset});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("显示图片"),
      ),
      body: PhotoView(
        imageProvider: MemoryImage(asset),
      ),
    );
  }
}
