import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvel_movie_fans_flutter/bean/UpdateUser.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';

class LoginUserInfoPage extends StatefulWidget {
  @override
  _LoginUserInfoPageState createState() => _LoginUserInfoPageState();
}

class _LoginUserInfoPageState extends State<LoginUserInfoPage> {
  UserBean loginUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataSource.getLoginUser().then((user) {
      if (user is UserBean) {
        setState(() {
          loginUser = user;
        });
      }
    });
  }

  void _exitCurrentUser() {
    Navigator.of(context).pop("exitLoginUser");
    UserDataSource.clearLoginUser();
    eventBus.fire("exitLoginUser");
  }

  void _showToast(String text,
      {Toast toastLength: Toast.LENGTH_SHORT,
      ToastGravity gravity: ToastGravity.BOTTOM}) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: toastLength,
        gravity: gravity,
        backgroundColor: THEME_COLOR);
  }

  void _showUpdateUserInfoDialog(String title, String key, String value) {
    TextEditingController _editingController =
        TextEditingController(text: value);

    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              content: TextField(
                onChanged: (value) {},
                autofocus: true,
                cursorColor: THEME_COLOR,
                inputFormatters: key == "age"?[WhitelistingTextInputFormatter(RegExp("[0123456789]"))]:[],
                keyboardType:
                    key == "age" ? TextInputType.number : TextInputType.text,
                controller: _editingController,
                decoration: InputDecoration(
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: THEME_COLOR)),
                    labelText: title,
                    contentPadding: EdgeInsets.all(10),
                    labelStyle: TextStyle(color: THEME_COLOR)),
              ),
              actions: <Widget>[
                FlatButton(
                  onPressed: () {
                    String newValue = _editingController.text;
                    if(newValue == value){
                      Navigator.of(context).pop();


                      return;
                    }
                    if (newValue.length == 0) {
                      _showToast("不能为空", gravity: ToastGravity.CENTER);
                    } else {

                      UserDataSource.updateUserInfo(loginUser.id, key, newValue,
                          success: (user) {
                        setState(() {
                          loginUser = user;
                          UserDataSource.saveLoginUser(user);
                          eventBus.fire(UpdateUserEvent(user, false));
                          if (key == "age") {
                            if(int.parse(newValue)>100){
                              _showToast("哇,原来你年纪这么大了", gravity: ToastGravity.CENTER);
                            }
                          } else {
                            _showToast("修改成功", gravity: ToastGravity.CENTER);
                          }
                        });
                      }, error: (msg) {
                        _showToast("修改失败:$msg");
                      });
                      Navigator.of(context).pop();
                    }
                  },
                  child: new Text("确定", style: TextStyle(color: THEME_COLOR)),
                )
              ],
            ));
  }

  void _showExitDialog() {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
              title: Text("退出当前用户?"),
              actions: <Widget>[
                new FlatButton(
                  child: new Text("取消", style: TextStyle(color: THEME_COLOR)),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                new FlatButton(
                  child: new Text(
                    "退出",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _exitCurrentUser();
                  },
                )
              ],
            ));
  }

  List<Widget> buildListWidget() {
    return <Widget>[
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            ImagePicker.pickImage(source: ImageSource.gallery).then((file) {
              print("choose file : ${file.path}");
              Fluttertoast.showToast(
                  msg: "正在上传头像..",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: THEME_GREY_COLOR);
              UserDataSource.uploadAvatar(loginUser.id, file, success: (user) {
                Fluttertoast.showToast(
                    msg: "修改成功",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    textColor: Colors.white,
                    backgroundColor: THEME_COLOR);

                setState(() {
                  loginUser = user;
                  eventBus.fire(UpdateUserEvent(user, false));
                  UserDataSource.saveLoginUser(user);
                });
              }, error: (msg) {
                Fluttertoast.showToast(
                    msg: "上传失败：$msg",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: THEME_GREY_COLOR);
              });
            });
          },
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("头像"),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Container(
                        width: 60.0,
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: THEME_COLOR,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(30.0),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: loginUser != null
                                ? Image.network(
                                        BASE_FILE_URL + loginUser.avatar)
                                    .image
                                : Image.asset("assets/images/placeholder.png")
                                    .image,
                          ),
                        ),
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: THEME_GREY_COLOR)
                  ],
                )
              ],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            _showUpdateUserInfoDialog("修改昵称", "nickName", loginUser.nickName);
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("昵称"),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(loginUser != null ? loginUser.nickName : ""),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: THEME_GREY_COLOR)
                  ],
                )
              ],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            _showUpdateUserInfoDialog("你是哪里人？", "sex", loginUser.sex);
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("族群"),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(loginUser != null ? loginUser.sex : ""),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: THEME_GREY_COLOR)
                  ],
                )
              ],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            _showUpdateUserInfoDialog("修改年龄", "age", "${loginUser.age}");
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("年龄"),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child: Text(loginUser != null ? "${loginUser.age}" : ""),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: THEME_GREY_COLOR)
                  ],
                )
              ],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            _showUpdateUserInfoDialog("个性签名", "slogan", "${loginUser.slogan}");
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Text("个性签名"),
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 10),
                      child:
                          Text(loginUser != null ? "${loginUser.slogan}" : ""),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        size: 16, color: THEME_GREY_COLOR)
                  ],
                )
              ],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
          radius: 1000,
          splashColor: THEME_COLOR,
          onTap: () {
            _showExitDialog();
          },
          child: Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
            child: Row(
              children: <Widget>[Text("退出当前用户")],
            ),
          )),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(loginUser);
            }),
        title: Text("个人信息"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: buildListWidget(),
        ),
      ),
    );
  }
}
