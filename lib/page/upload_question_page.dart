import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';

class UploadQuestionPage extends StatefulWidget {
  @override
  _UploadQuestionPageState createState() => _UploadQuestionPageState();
}

class _UploadQuestionPageState extends State<UploadQuestionPage> {
  File imageFile;

  UserBean loginUser;
  TextEditingController _titleEditingController = new TextEditingController();
  TextEditingController _answerEditingController = new TextEditingController();
  TextEditingController _keywordEditingController = new TextEditingController();
  TextEditingController _pointEditingController = new TextEditingController();
  bool _allInputEnable = true;
  bool _isUploading = false;
  String _titleErrorText = "";
  String _answerErrorText = "";
  String _keywordErrorText = "";
  String _pointErrorText = "";
  FocusNode _titleFocusNode = FocusNode();
  FocusNode _answerFocusNode = FocusNode();
  FocusNode _keywordFocusNode = FocusNode();
  FocusNode _pointFocusNode = FocusNode();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataSource.getLoginUser().then((user) {
      setState(() {
        loginUser = user;
      });
    });
  }

  void _setAllInputEnable(bool enable) {
    setState(() {
      _allInputEnable = enable;
      _isUploading = !enable;
    });
  }

  void _changeErrorText(
      {String answerErrorText = "",
      String titleErrorText = "",
      String keywordErrorText = "",
      String pointErrorText = ""}) {
    setState(() {
      _answerErrorText = answerErrorText;
      _titleErrorText = titleErrorText;
      _keywordErrorText = keywordErrorText;
      _pointErrorText = pointErrorText;
    });
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

  void _uploadQuestion() {
    if (_isUploading) {
      Fluttertoast.showToast(
          msg: "正在上传中，请稍后",
          backgroundColor: THEME_COLOR,
          textColor: Colors.white);
      return;
    }

    String title = _titleEditingController.text;
    String answer = _answerEditingController.text;
    String keyword = _keywordEditingController.text;
    String point = _pointEditingController.text;

    if (imageFile == null) {
      _showToast("请选择图片");
      return;
    }
    if (title.length == 0) {
      setState(() {
        _changeErrorText(titleErrorText: "标题不能为空");
        //切换光标
        FocusScope.of(context).requestFocus(_titleFocusNode);
        _titleEditingController.selection = TextSelection.collapsed(offset: 0);
      });

      return;
    }
    if (answer.length == 0) {
      setState(() {
        _changeErrorText(answerErrorText: "答案不能为空");

        //切换光标
        FocusScope.of(context).requestFocus(_answerFocusNode);
        _answerEditingController.selection = TextSelection.collapsed(offset: 0);
      });

      return;
    }

    if (keyword.length == 0) {
      setState(() {
        _changeErrorText(answerErrorText: "关键词不能为空");

        //切换光标
        FocusScope.of(context).requestFocus(_keywordFocusNode);
        _keywordEditingController.selection =
            TextSelection.collapsed(offset: 0);
      });

      return;
    }

    if (point.length == 0) {
      setState(() {
        _changeErrorText(pointErrorText: "分数不能为空");
        //切换光标
        FocusScope.of(context).requestFocus(_pointFocusNode);
        _pointEditingController.selection = TextSelection.collapsed(offset: 0);
      });
      return;
    } else if (int.parse(point) == 0) {
      _changeErrorText(pointErrorText: "分数不能为0");
      return;
    }
    _setAllInputEnable(false);

    UserDataSource.uploadQuestion(
        loginUser.id, imageFile, title, answer, keyword, point, success: (msg) {
      _setAllInputEnable(true);
      Fluttertoast.showToast(
          msg: "上传成功", backgroundColor: THEME_COLOR, textColor: Colors.white);

      Future.delayed(Duration(milliseconds: 500)).then((data){

        Navigator.of(context).pop("uploadNewQuestion");
      });
    }, error: (msg) {
      _setAllInputEnable(true);

      Fluttertoast.showToast(
          msg: "上传失败：$msg",
          backgroundColor: THEME_COLOR,
          textColor: Colors.white);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("添加问题"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16 / 9,
              child: InkWell(
                splashColor: THEME_COLOR,
                onTap: () {
                  ImagePicker.pickImage(source: ImageSource.gallery)
                      .then((file) {
                    setState(() {
                      imageFile = file;
                    });
                  });
                },
                child: imageFile == null
                    ? Center(
                        child: Text("点击添加图片"),
                      )
                    : Container(
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.cover,
                                image: Image.file(imageFile).image)),
                      ),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  onChanged: (value) {
                    if (_titleErrorText != "" && value.length > 0) {
                      _changeErrorText();
                    }
                  },
                  enabled: _allInputEnable,
                  focusNode: _titleFocusNode,
                  cursorColor: THEME_COLOR,
                  keyboardType: TextInputType.text,
                  controller: _titleEditingController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: THEME_COLOR)),
                      labelText: "问题",
                      errorText: _titleErrorText != "" ? _titleErrorText : null,
                      contentPadding: EdgeInsets.all(10),
                      labelStyle: TextStyle(
                          color: _titleFocusNode.hasFocus
                              ? THEME_COLOR
                              : THEME_GREY_COLOR)),
                )),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  onChanged: (value) {
                    if (_answerErrorText != "" && value.length > 0) {
                      _changeErrorText();
                    }
                  },
                  enabled: _allInputEnable,
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp("[ ~`!_-]"))
                  ],
                  focusNode: _answerFocusNode,
                  cursorColor: THEME_COLOR,
                  keyboardType: TextInputType.text,
                  controller: _answerEditingController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: THEME_COLOR)),
                      labelText: "答案",
                      errorText:
                          _answerErrorText != "" ? _answerErrorText : null,
                      contentPadding: EdgeInsets.all(10),
                      labelStyle: TextStyle(
                          color: _answerFocusNode.hasFocus
                              ? THEME_COLOR
                              : THEME_GREY_COLOR)),
                )),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  onChanged: (value) {
                    if (_keywordErrorText != "" && value.length > 0) {
                      _changeErrorText();
                    }
                  },
                  maxLength: 21,
                  inputFormatters: [
                    BlacklistingTextInputFormatter(RegExp("[ ]"))
                  ],
                  enabled: _allInputEnable,
                  focusNode: _keywordFocusNode,
                  cursorColor: THEME_COLOR,
                  keyboardType: TextInputType.text,
                  controller: _keywordEditingController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: THEME_COLOR)),
                      labelText: "关键字，必须包含答案",
                      errorText:
                          _keywordErrorText != "" ? _keywordErrorText : null,
                      contentPadding: EdgeInsets.all(10),
                      labelStyle: TextStyle(
                          color: _keywordFocusNode.hasFocus
                              ? THEME_COLOR
                              : THEME_GREY_COLOR)),
                )),
            Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: TextField(
                  onChanged: (value) {
                    if (_pointErrorText != "" && value.length > 0) {
                      _changeErrorText();
                    }
                  },
                  inputFormatters: [
                    WhitelistingTextInputFormatter(RegExp("[0123456789]"))
                  ],
                  enabled: _allInputEnable,
                  focusNode: _pointFocusNode,
                  cursorColor: THEME_COLOR,
                  keyboardType: TextInputType.number,
                  controller: _pointEditingController,
                  decoration: InputDecoration(
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: THEME_COLOR)),
                      labelText: "分数",
                      errorText: _pointErrorText != "" ? _pointErrorText : null,
                      contentPadding: EdgeInsets.all(10),
                      labelStyle: TextStyle(
                          color: _pointFocusNode.hasFocus
                              ? THEME_COLOR
                              : THEME_GREY_COLOR)),
                )),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: FlatButton(
                    onPressed: _uploadQuestion,
                    splashColor: THEME_GREY_COLOR,
                    color: _isUploading ? Colors.grey : THEME_COLOR,
                    child: Padding(
                      padding: EdgeInsets.all(18),
                      child: Text(
                        _isUploading ? "上传中" : "提交问题",
                        style: TextStyle(color: Colors.white),
                      ),
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
