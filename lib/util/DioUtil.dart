import 'package:dio/dio.dart';
import 'dart:convert';
import 'api_constants.dart';
import 'dart:io';

class NetUtil {
  static const String GET = "get";
  static const String POST = "post";


  //get请求
  static void get(String url, Function callBack,
      {Map<String, String> params, Function errorCallBack}) async {
    _request(BASE_URL + url, callBack,
        method: GET, params: params, errorCallBack: errorCallBack);
  }

  //post请求
  static void post(String url, Function callBack,
      {Map<String, String> params, Function errorCallBack}) async {
    _request(BASE_URL+url, callBack,
        method: POST, params: params, errorCallBack: errorCallBack);
  }
  static void postFile(String url,UploadFileInfo fileInfo,{Map<String, String> params,Function callBack,Function errorCallBack}) async{
    Map<String,dynamic> data = {
      "file":fileInfo
    };
    if(params!=null){
      params.forEach((key,value){

        data[key]=value;
      });
    }
    FormData formData = FormData.from(data);

    try{
      Dio dio = new Dio();
      Response response = await dio.post(url, data: formData);
      var statusCode = response.statusCode;
      String errorMsg = "";
      //处理错误部分
      if (statusCode !=200) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
        return;
      }
      if (callBack != null) {
        if(response.data['code']==SUCCESS_CODE){
          callBack(response.data["data"]);

        }else{
          _handError(errorCallBack, response.data["msg"]);
        }

        print("<net> response data:" + json.encode(response.data["data"]));
      }
    }catch(exception){
      _handError(errorCallBack, exception.toString());

    }
  }

  //具体的还是要看返回数据的基本结构
  //公共代码部分
  static void _request(String url, Function callBack,
      {String method,
        Map<String, String> params,
        Function errorCallBack}) async {
    print("<net> url :<" + method + ">" + url);

    if (params != null && params.isNotEmpty) {
      print("<net> params :" + params.toString());
    }

    String errorMsg = "";
    int statusCode;

    try {
      Response response;
      if (method == GET) {
        //组合GET请求的参数
        if (params != null && params.isNotEmpty) {
          StringBuffer sb = new StringBuffer("?");
          params.forEach((key, value) {
            sb.write("$key" + "=" + "$value" + "&");
          });
          String paramStr = sb.toString();
          paramStr = paramStr.substring(0, paramStr.length - 1);
          url += paramStr;
        }
        response = await Dio().get(url);
      } else {
        if (params != null && params.isNotEmpty) {
          response = await Dio().post(url, data: params);
        } else {
          response = await Dio().post(url);
        }
      }

      statusCode = response.statusCode;

      //处理错误部分
      if (statusCode !=200) {
        errorMsg = "网络请求错误,状态码:" + statusCode.toString();
        _handError(errorCallBack, errorMsg);
        return;
      }

      if (callBack != null) {
        if(response.data['code']==SUCCESS_CODE){
          callBack(response.data["data"]);

        }else{
          _handError(errorCallBack, response.data["msg"]);
        }

        print("<net> response data:" + json.encode(response.data["data"]));
      }
    } catch (exception) {
      _handError(errorCallBack, exception.toString());
    }
  }

  //处理异常
  static void _handError(Function errorCallback, String errorMsg) {
    if (errorCallback != null) {
      errorCallback(errorMsg);
    }
    print("<net> errorMsg :" + errorMsg);
  }
}