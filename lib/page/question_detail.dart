import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/user_bean.dart';
import 'package:marvel_movie_fans_flutter/bean/question_bean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'common_question_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
class QuestionDetailPage extends StatefulWidget {

  final NoAdminQuestionBean questionBean;

  const QuestionDetailPage( this.questionBean);
  @override
  _QuestionDetailPageState createState() => _QuestionDetailPageState();
}

class _QuestionDetailPageState extends State<QuestionDetailPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        backgroundColor: THEME_COLOR,
        leading: IconButton(
          splashColor: THEME_GREY_COLOR,
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title:Text( widget.questionBean.title),

      ),
      body: QuestionPage(widget.questionBean,rightAnswerCallback: (answer){


        UserDataSource.getLoginUser().then((loginUser){
          UserDataSource.answerQuestion(loginUser.id, widget.questionBean.id,success: (data){

            print(data);
          },fail: (msg){
            print("fail $msg");

          });
        });
        Fluttertoast.showToast(
          msg: "恭喜你，回答正确",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: THEME_COLOR,
          textColor: Colors.white,
        );
        Future.delayed(Duration(milliseconds: 500)).whenComplete((){
          Navigator.of(context).pop(widget.questionBean);
        });

      },wrongAnswerCallback: (wrong){
        Fluttertoast.showToast(
          msg: "回答不正确",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.white,
        );
      },),

    );
  }
}
