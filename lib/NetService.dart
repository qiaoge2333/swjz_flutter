import 'package:dio/dio.dart';

class NetService {
  static const String Base_URL = "192.168.1.101:8081";
  static const String GET = 'GET';
  static const String POST = "POST";

  static void get(String url, Function successCallBack,
      {Map<String, String> params, Function errorCallBack}) {
    _request(url, successCallBack,
        method: GET, params: params, errorCallBack: errorCallBack);
  }

  static void post(String url, Function successCallBack,
      {Map<String, String> params, Function errorCallBack}) {
    _request(url, successCallBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }

  static void _request(String url, Function callBack,
      {String method,
      Map<String, String> params,
      Function errorCallBack}) async {
    String errorMsg = "";
    int statusCode;

    try {
      Response response;
      BaseOptions options = new BaseOptions(
        connectTimeout: 15000,
        receiveTimeout: 15000,
        baseUrl: Base_URL,
      );
      Dio dio = new Dio(options);
      if (method == GET) {
        response = await dio.get(url, queryParameters: params);
      } else {
        response = await dio.post(url, data: params);
      }
      statusCode = response.statusCode;
      if (statusCode < 0) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
        return;
      }
    } catch (exception) {
      _handError(errorCallBack, exception.toString());
    }
  }

  static void _handError(Function errorCallback, String errorMsg) {
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
  }
}
