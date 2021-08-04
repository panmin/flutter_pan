import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class HttpManager {
  static Utf8Decoder _utf8decoder = Utf8Decoder();

  // 此处可以添加公共的header，默认值为[]
  static Map<String, String>? _headers = {
    'Accept': 'application/json, text/plain, */*',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'zh-CN,zh;q=0.9',
    'Connection': 'keep-alive',
    'Content-Type': 'application/json',
    'User-Agent':
    'Mozilla/5.0 (iPhone; CPU iPhone OS 11_0 like Mac OS X) AppleWebKit/604.1.38 (KHTML, like Gecko) Version/11.0 Mobile/15A372 Safari/604.1',
  };


  static Future get(String url, {Map<String, String>? headers}) async {
    try {
      var uri = Uri.parse(url);
      if (headers != null) {
        _headers!.addAll(headers);
      }
      var response = await http.get(uri, headers: _headers);
      if (response.statusCode == 200) {
        var result = json.decode(_utf8decoder.convert(response.bodyBytes));
        // TODO 此处可以根据业务添加json转对象操作和错误码处理
        return result;
      } else {
        // TODO 此处加入错误分类处理
        throw HttpException("网络请求失败", uri: uri);
      }
    } catch (e) {
      return Future.error(e);
    }
  }

  static Future post(String url, Map<String, String> params,
      {Map<String, String>? headers}) async {
    try {
      var uri = Uri.parse(url);
      if (headers != null) {
        _headers!.addAll(headers);
      }
      var response = await http.post(uri, body: params, headers: _headers);
      if (response.statusCode == 200) {
        var result = json.decode(_utf8decoder.convert(response.bodyBytes));
        // TODO 此处可以根据业务添加json转对象操作和错误码处理
        return result;
      } else {
        // TODO 此处加入错误分类处理
        throw HttpException("网络请求失败", uri: uri);
      }
    } catch (e) {
      return Future.error(e);
    }
  }
}
