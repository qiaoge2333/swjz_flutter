import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:test1/model/userinfo.dart';

var account = new Account(loaded: false);

Future scan() async {
  try {
    String barcode = await BarcodeScanner.scan();
    return barcode;
  } on PlatformException catch (e) {
    if (e.code == BarcodeScanner.CameraAccessDenied) {
      print("未授予App相机权限");
    } else {
      print("扫码错误:$e");
    }
  } on FormatException {
    print("取消扫码");
  } catch (e) {
    print("扫码错误: $e");
  }
  return "";
}
