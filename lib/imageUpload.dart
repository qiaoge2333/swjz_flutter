import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test1/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:test1/loadingDialog.dart';

class ImageUpload extends StatefulWidget {
  final String ypCode;
  final int currentImages;
  final String type;
  ImageUpload(
      {Key key,
      @required this.currentImages,
      @required this.ypCode,
      @required this.type})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ImageUpload(
        currentImages: currentImages,
        ypCode: ypCode,
        type: type,
      );
}

class _ImageUpload extends State<ImageUpload> {
  final int currentImages;
  final String ypCode;
  final String type;
  bool uploading = false;
  List<Asset> _images = new List<Asset>();

  _ImageUpload(
      {Key key,
      @required this.currentImages,
      @required this.ypCode,
      @required this.type});

  Future _getImageFromCamera() async {
    var count = 6 - currentImages - _images.length;
    if (count <= 0) {
      return;
    }
    var image = await MultiImagePicker.pickImages(
        maxImages: count,
        enableCamera: true,
        materialOptions: MaterialOptions(
          startInAllView: true,
          allViewTitle: "所有照片",
          textOnNothingSelected: "没有选择照片",
        ));
    setState(() {
      _images.addAll(image);
    });
  }

  Future uploadTest() async {
    if (_images.length == 0) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return new AlertDialog(
              title: Row(
                children: <Widget>[
                  Icon(
                    Icons.warning,
                    color: Colors.red,
                  ),
                  SizedBox(
                    width: 20.0,
                  ),
                  Text("请选择图片"),
                  CloseButton(),
                ],
              ),
            );
          });
    } else {
      setState(() {
        uploading = true;
      });
      await uploadImages().then((result) {
        setState(() {
          uploading = false;
        });
        Navigator.pop(context, true);
      });
      // showDialog(
      //     context: context,
      //     barrierDismissible: false,
      //     builder: (context) => new LoadingDialog(text: "图片上传中"));
    }
  }

  void showBigImage() {}

  Future uploadImages() async {
    for (int i = 0; i < _images.length; i++) {
      ByteData byteData = await _images[i].getByteData();
      List<int> imageData = byteData.buffer.asUint8List();
      DateTime uploadDatetime = new DateTime.now();
      MultipartFile multipartFile = MultipartFile.fromBytes(
        imageData,
        filename: uploadDatetime.millisecondsSinceEpoch.toString(),
        contentType: MediaType("image", "jpg"),
      );
      FormData formData = FormData.fromMap(
          {"files": multipartFile, "type": type, "yp_code": ypCode});
      try {
        var res = await dio.post("/image/saveImage", data: formData);
        if (res.data["msg"] == "上传成功") {
          Fluttertoast.showToast(msg: "第${i + 1}图片上传成功!");
        } else {
          Fluttertoast.showToast(msg: "第${i + 1}图片上传失败!");
        }
      } catch (e) {
        Fluttertoast.showToast(msg: "第${i + 1}图片上传失败!");
      }
    }
    return true;
  }

  Widget buildGridView() {
    if (_images.length > 0)
      return GridView.count(
          crossAxisCount: 3,
          children: List.generate(_images.length, (index) {
            Asset asset = _images[index];
            // return Text("草泥马");
            return LongPressDraggable(
              feedback: AssetThumb(asset: asset, width: 100, height: 100),
              onDragEnd: (detail) {
                if (detail.wasAccepted) {
                  setState(() {
                    _images.removeAt(index);
                  });
                }
              },
              onDragCompleted: () {
                print("完成");
              },
              child: AssetThumb(asset: asset, width: 300, height: 300),
            );
          }));
    return Container(color: Colors.white);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("请选择图片并上传")),
        body: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RaisedButton(
                child: Text("选择图片"),
                onPressed: uploading ? null : () => _getImageFromCamera(),
              ),
              RaisedButton(
                  onPressed: uploading ? null : () => uploadTest(),
                  child: Text("上传")),
              SizedBox(
                width: 10.0,
              ),
              DragTarget(onAccept: (value) {
                print(value);
              }, builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) {
                return Icon(Icons.delete);
              }),
            ],
          ),
          Expanded(
            child: buildGridView(),
          )
        ]));
  }
}
