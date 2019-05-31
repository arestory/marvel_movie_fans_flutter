import 'package:flutter/services.dart';
import 'package:marvel_movie_fans_flutter/util/DioUtil.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/bean/QuestionBean.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/bean/NoAdminQuestionBean.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:dio/dio.dart';

class QuestionDataSource {
  static void getQuestionList(int page,
      {int count = 10,
      String userId,
      DataCallBack<List<QuestionBean>> callback,
      ErrorCallback errorCallback}) {
    Map<String, String> map = Map<String, String>();

    if (userId != null) {
      map["userId"] = userId;
    }
    NetUtil.get(
        "$GET_QUESTION_LIST$page/$count",
        (data) {
          List<QuestionBean> list = <QuestionBean>[];
          for (var value in data) {
            list.add(QuestionBean.fromJsonMap(value));
          }
          if (callback != null) {
            callback(list);
          }
        },
        params: map,
        errorCallBack: (msg) {
          if (errorCallback != null) {
            errorCallback(msg);
          }
        });
  }

  static void getQuestionCount(
      {DataCallBack<int> callback, ErrorCallback errorCallback}) {
    NetUtil.get(GET_QUESTION_COUNT, (count) {
      callback(count);
    }, errorCallBack: (msg) {
      errorCallback(msg);
    });
  }

  static void getNoAdminQuestion(int page,
      {String userId,
      String createUserId,
      int count: 20,
        int auth :1,
      DataCallBack<List<NoAdminQuestionBean>> callback,
      ErrorCallback errorCallback}) {
    Map<String, String> map = Map<String, String>();
    if (userId != null) {
      map['userId'] = userId;
    }
    if (createUserId != null) {
      map['createUserId'] = createUserId;
    }
    map['auth']="$auth";

    NetUtil.get(
        GET_QUESTION_NOT_ADMIN_LIST + "$page/$count",
        (data) {
          List<NoAdminQuestionBean> list = <NoAdminQuestionBean>[];
          for (var value in data) {
            list.add(NoAdminQuestionBean.fromJsonMap(value));
          }
          callback(list);
        },
        params: map,
        errorCallBack: (msg) {
          errorCallback(msg);
        });
  }

  static void getRandomQuestion(
      {String userId,
      DataCallBack<QuestionBean> callback,
      ErrorCallback errorCallback}) {
    Map<String, String> map = Map<String, String>();
    map['userId'] = userId;
    NetUtil.get(
        GET_RANDOM_ONE,
        (data) {
          QuestionBean questionBean = QuestionBean.fromJsonMap(data);

          callback(questionBean);
        },
        params: map,
        errorCallBack: (msg) {
          print("error2:" + msg);

          errorCallback(msg);
        });
  }
}

class UserDataSource {
  static void login(
      {String account,
      String password,
      DataCallBack<UserBean> success,
      ErrorCallback fail}) {
    Map<String, String> map = Map<String, String>();

    map['account'] = account;
    map['password'] = password;
    NetUtil.post(
        USER_LOGIN,
        (data) {
          success(UserBean.fromJsonMap(data));
        },
        params: map,
        errorCallBack: (msg) {
          fail(msg);
        });
  }

  static void register(
      {String account,
      String password,
      String confirmPassword,
      DataCallBack<UserBean> success,
      ErrorCallback fail}) {
    Map<String, String> map = Map<String, String>();

    map['account'] = account;
    map['password'] = password;
    map['confirmPassword'] = confirmPassword;
    NetUtil.post(
        USER_REGISTER,
        (data) {
          success(UserBean.fromJsonMap(data));
        },
        params: map,
        errorCallBack: (msg) {
          fail(msg);
        });
  }

  static void uploadAvatar(String userId, File imageFile,
      {DataCallBack<UserBean> success, ErrorCallback error}) {
    NetUtil.postFile(
        "${BASE_URL}user/$userId/uploadAvatar",
        UploadFileInfo(imageFile, imageFile.path.split("/").last,
            contentType: ContentType.parse("image/jpg")), callBack: (data) {
      print("上传成功");
      if (success != null) {
        success(UserBean.fromJsonMap(data));
      }
    }, errorCallBack: (msg) {
      print("上传失败 ： $msg");
      if (error != null) {
        error("$msg");
      }
    });
  }

  static void uploadQuestion(String userId, File imageFile, String title,
      String answer, String keywords, String point,
      {DataCallBack success, ErrorCallback error}) {
    NetUtil.postFile(
        "${BASE_URL}question/upload",
        UploadFileInfo(imageFile, imageFile.path.split("/").last,
            contentType: ContentType.parse("image/jpg")),
        params: {
          "createUserId":userId,
          "title": title,
          "answer": answer,
          "keywords": keywords,
          "point": point,
        }, callBack: (data) {
      print("上传成功");
      if (success != null) {
        success("上传成功");
      }
    }, errorCallBack: (msg) {
      print("上传失败 ： $msg");
      if (error != null) {
        error("$msg");
      }
    });
  }

  static void updateUserInfo(String userId, String key, String value,
      {DataCallBack<UserBean> success, ErrorCallback error}) {
    NetUtil.post(
        "$USER_INFO$userId/update",
        (data) {
          if (success != null) {
            success(UserBean.fromJsonMap(data));
          }
        },
        params: {key: value},
        errorCallBack: (msg) {
          if (error != null) {
            error(msg);
          }
        });
  }

  static void saveLoginUser(UserBean user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("loginUser", json.encode(user));
  }

  static Future<UserBean> getLoginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String userJson = prefs.getString("loginUser");
    if (userJson != null && userJson != "") {
      return Future.value(UserBean.fromJsonMap(json.decode(userJson)));
    }

    return null;
  }

  static void clearLoginUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove("loginUser");
  }

  static void forceSaveLoginUserFromLastNotFlutterVersion() async {
    try {
      MethodChannel platform = MethodChannel('loginUser');
      //第一个参数 tryToast为Java/oc中的方法名(后面会讲)，第二个参数数组为传参数组
      String user = await platform.invokeMethod('getLoginUser');
      if (user != null && user != "") {
        var userBean = UserBean.fromJsonMap(json.decode(user));
        if (userBean != null) {
          saveLoginUser(userBean);
          //"清理旧的用户信息
          int code = await platform.invokeMethod('clearLoginUser');
          if (code == 200) {
            print("清理旧的用户信息");
          }
        }
      }
    }
    //result 为回调的结果
    on PlatformException catch (e) {}
  }

  static void getUserInfo(String userId,
      {DataCallBack<UserBean> success, ErrorCallback fail}) {
    NetUtil.get(
        "$USER_INFO/$userId",
        (data) {
          success(UserBean.fromJsonMap(data));
        },
        params: null,
        errorCallBack: (msg) {
          fail(msg);
        });
  }
}

typedef DataCallBack<T> = void Function(T data);

typedef ErrorCallback = void Function(String msg);
