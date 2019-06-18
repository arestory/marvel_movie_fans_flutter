import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/bean/user_bean.dart';

class CommitFeedbackPage extends StatefulWidget {
  final String questionId;

  const CommitFeedbackPage({this.questionId});

  @override
  _CommitFeedbackPageState createState() => _CommitFeedbackPageState();
}

class _CommitFeedbackPageState extends State<CommitFeedbackPage> {
  String userId;
  bool allInputEnable = true;

  String errorText = "";
  TextEditingController editingController = new TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataSource.getLoginUser().then((user) {
      if (user is UserBean) {
        setState(() {
          userId = user.id;
        });
      }
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

  void setAllInputEnable(bool enable) {
    setState(() {
      allInputEnable = enable;
    });
  }

  void commitFeedback() {
    String content = editingController.text;
    if (content.length == 0) {
      setState(() {
        errorText = "内容不能为空";
      });
      return;
    }
    setAllInputEnable(false);
    UserDataSource.commitFeedback(content,
        userId: userId,
        questionId: widget.questionId,
        success: (data) {

          setAllInputEnable(true);
          _showToast("感谢你的宝贵意见");
          Future.delayed(Duration(milliseconds: 300)).then((_){

            Navigator.of(context).pop();
          });

        },
        fail: (msg) {

          setAllInputEnable(false);
          setState(() {
            errorText = "提交失败：$msg";
          });

        });
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
                Navigator.of(context).pop();
              }),
          title: Text("反馈问题"),
        ),
        body: SingleChildScrollView(

          child: Column(
            children: <Widget>[
              TextField(
                controller: editingController,
                enabled: allInputEnable,
                autofocus: true,
                maxLines: 10,
                maxLength: 200,
                decoration: InputDecoration(
                    errorText: errorText, contentPadding: EdgeInsets.all(10)),
                textAlign: TextAlign.start,
              ),
              !allInputEnable
                  ? Padding(
                padding: EdgeInsets.only(top: 15),
                child: Container(
                  height: 3,
                  child: LinearProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(THEME_COLOR)),
                ),
              )
                  : Text(""),
              Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: FlatButton(
                      onPressed: allInputEnable
                          ? commitFeedback
                          : () {},
                      color: allInputEnable ? THEME_COLOR : THEME_GREY_COLOR,
                      textColor: Colors.white,
                      splashColor: THEME_GREY_COLOR,
                      child: Text(allInputEnable ? "提交" : "提交中"),
                    )),
              )
            ],
          ),
        ));
  }
}
