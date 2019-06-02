import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'before_regitser_question_page.dart';

class UserLoginPage extends StatefulWidget {
  @override
  _UserLoginPageState createState() => _UserLoginPageState();
}

class _UserLoginPageState extends State<UserLoginPage> {
  TextEditingController _accountEditingController = new TextEditingController();
  TextEditingController _pwdEditingController = new TextEditingController();
  TextEditingController _pwd2EditingController = new TextEditingController();
  String _loginTitle = "登录";
  String _registerTitle = "注册";
  bool _allInputEnable = true;
  String _accountErrorText = "";
  String _pwdErrorText = "";
  String _pwd2ErrorText = "";
  FocusNode _accountFocusNode = FocusNode();
  FocusNode _pwdFocusNode = FocusNode();
  FocusNode _pwd2FocusNode = FocusNode();
  bool _pwd2Visible = false;

  UserBean loginUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _accountEditingController.addListener(() {});
    _pwdEditingController.addListener(() {});
    _pwd2EditingController.addListener(() {});
  }

  void _setAllInputEnable(bool enable) {
    setState(() {
      _allInputEnable = enable;
    });
  }

  void _changeErrorText(
      {String accountErrorText = "",
      String pwdErrorText = "",
      String pwd2ErrorText = ""}) {
    setState(() {
      _accountErrorText = accountErrorText;
      _pwdErrorText = pwdErrorText;
      _pwd2ErrorText = pwd2ErrorText;
    });
  }

  void _login() {
    String account = _accountEditingController.text;
    String pwd = _pwdEditingController.text;
    if (account.length == 0) {
      setState(() {
        _changeErrorText(accountErrorText: "账号不能为空");
        //切换光标
        FocusScope.of(context).requestFocus(_accountFocusNode);
        _accountEditingController.selection =
            TextSelection.collapsed(offset: 0);
      });

      return;
    }
    if (pwd.length == 0) {
      _changeErrorText(pwdErrorText: "密码不能为空");
      //切换光标
      FocusScope.of(context).requestFocus(_pwdFocusNode);
      _pwdEditingController.selection = TextSelection.collapsed(offset: 0);

      return;
    }

    _setAllInputEnable(false);

    UserDataSource.login(
        account: account,
        password: pwd,
        success: (user) {
          _setAllInputEnable(true);
          print(user.avatar);
          _changeErrorText();

          loginSuccess(user);
        },
        fail: (msg) {
          _setAllInputEnable(true);
          _changeErrorText(pwdErrorText: msg);
        });
  }

  void _register() {
    String account = _accountEditingController.text;
    String pwd = _pwdEditingController.text;
    String pwd2 = _pwd2EditingController.text;
    if (account.length == 0) {
      setState(() {
        _changeErrorText(accountErrorText: "账号不能为空");

        //切换光标
        FocusScope.of(context).requestFocus(_accountFocusNode);
        _accountEditingController.selection =
            TextSelection.collapsed(offset: 0);
      });

      return;
    }
    if (pwd.length == 0) {
      _changeErrorText(pwdErrorText: "密码不能为空");

      //切换光标
      FocusScope.of(context).requestFocus(_pwdFocusNode);
      _pwdEditingController.selection = TextSelection.collapsed(offset: 0);

      return;
    }
    if (pwd2.length == 0) {
      _changeErrorText(pwd2ErrorText: "确认密码不能为空");
      FocusScope.of(context).requestFocus(_pwd2FocusNode);
      _pwd2EditingController.selection = TextSelection.collapsed(offset: 0);

      return;
    }
    if (pwd != pwd2) {
      _changeErrorText(pwd2ErrorText: "两次密码不一致");
      FocusScope.of(context).requestFocus(_pwd2FocusNode);
      _pwd2EditingController.selection =
          TextSelection.collapsed(offset: _pwd2EditingController.text.length);
      return;
    }

    Fluttertoast.showToast(
        msg: "必须答对一条问题，才能完成注册",
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: THEME_COLOR);
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return BeforeRegisterQuestionPage();
    })).then((result) {
      if (result == "success") {
        _setAllInputEnable(false);

        UserDataSource.register(
            account: account,
            password: pwd,
            confirmPassword: pwd2,
            success: (user) {

              loginSuccess(user,title: "注册成功");

            },
            fail: (msg) {
              _changeErrorText(accountErrorText: msg);
              _setAllInputEnable(true);
            });
      }
    });
  }

  void loginSuccess(UserBean user,{String title:"登录成功"}){

    Fluttertoast.showToast(
        msg: title,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
        backgroundColor: THEME_COLOR);

    _setAllInputEnable(true);
    UserDataSource.saveLoginUser(user);
    eventBus.fire(user);
    Future.delayed(Duration(milliseconds: 500)).then((data){

      Navigator.of(context).pop(user);
    });

  }


  List<Widget> buildListView() {
    return <Widget>[
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            onChanged: (value) {
              if (_accountErrorText != "" && value.length > 0) {
                _changeErrorText();
              }
            },
            enabled: _allInputEnable,
            maxLength: 11,
            autofocus: true,
            focusNode: _accountFocusNode,
            cursorColor: THEME_COLOR,
            keyboardType: TextInputType.text,
            controller: _accountEditingController,
            inputFormatters: [ BlacklistingTextInputFormatter(RegExp("[ ]"))],
            decoration: InputDecoration(
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: THEME_COLOR)),
                labelText: "账号",
                errorText: _accountErrorText != "" ? _accountErrorText : null,
                contentPadding: EdgeInsets.all(10),
                labelStyle: TextStyle(
                    color: _accountFocusNode.hasFocus
                        ? THEME_COLOR
                        : THEME_GREY_COLOR)),
          )),
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: TextField(
            onChanged: (value) {
              if (_pwdErrorText != "" && value.length > 0) {
                _changeErrorText();
              }
            },
            enabled: _allInputEnable,
            autofocus: true,
            focusNode: _pwdFocusNode,
            cursorColor: THEME_COLOR,
            keyboardType: TextInputType.text,
            controller: _pwdEditingController,
            obscureText: true,
            maxLength: 20,
            inputFormatters: [ BlacklistingTextInputFormatter(RegExp("[ ]"))],
            decoration: InputDecoration(
                errorText: _pwdErrorText != "" ? _pwdErrorText : null,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: THEME_COLOR)),
                labelText: "密码",
                contentPadding: EdgeInsets.all(10),
                labelStyle: TextStyle(
                    color: _pwdFocusNode.hasFocus
                        ? THEME_COLOR
                        : THEME_GREY_COLOR)),
          )),
      Padding(
          padding: EdgeInsets.only(left: 10, right: 10),
          child: Offstage(
            offstage: !_pwd2Visible,
            child: TextField(
              onChanged: (value) {
                if (_pwd2ErrorText != "" && value.length > 0) {
                  _changeErrorText();
                }
              },
              enabled: _allInputEnable,
              autofocus: true,
              focusNode: _pwd2FocusNode,
              cursorColor: THEME_COLOR,
              keyboardType: TextInputType.text,
              controller: _pwd2EditingController,
              maxLength: 20,
              obscureText: true,
              inputFormatters: [ BlacklistingTextInputFormatter(RegExp("[ ]"))],
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: THEME_COLOR)),
                  labelText: "确认密码",
                  errorText: _pwd2ErrorText != "" ? _pwd2ErrorText : null,
                  contentPadding: EdgeInsets.all(10),
                  labelStyle: TextStyle(
                      color: _pwd2FocusNode.hasFocus
                          ? THEME_COLOR
                          : THEME_GREY_COLOR)),
            ),
          )),
      Offstage(
        offstage: _allInputEnable,
        child: Padding(
            padding: EdgeInsets.all(10),
            child: Container(
              height: 3,
              child: LinearProgressIndicator(
                backgroundColor: THEME_GREY_COLOR,
                valueColor: AlwaysStoppedAnimation(THEME_COLOR),
              ),
            )),
      ),
      Padding(
          padding: EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              Expanded(
                  child: Offstage(
                offstage: _pwd2Visible,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _pwd2Visible = true;
                    });
                  },
                  child: Text(
                    "我要注册",
                    style: TextStyle(color: THEME_COLOR),
                  ),
                ),
              )),
              FlatButton(
                onPressed: _pwd2Visible ? _register : _login,
                color: THEME_COLOR,
                splashColor: THEME_GREY_COLOR,
                child: Text(
                  _pwd2Visible ? _registerTitle : _loginTitle,
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          ))
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: THEME_COLOR,
        title: Text(_pwd2Visible ? _registerTitle : _loginTitle),
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            }),
      ),
      body: ListView(
        shrinkWrap: true,
        children: buildListView(),
      ),
    );
  }
}
