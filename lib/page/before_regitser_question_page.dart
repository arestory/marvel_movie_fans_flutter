import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/widget/state_layout.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'common_question_page.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/bean/question_bean.dart';

class BeforeRegisterQuestionPage extends StatefulWidget {


  @override
  _BeforeRegisterQuestionPageState createState() => _BeforeRegisterQuestionPageState();
}

class _BeforeRegisterQuestionPageState extends State<BeforeRegisterQuestionPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  String _title = "";

  QuestionBean _currentQuestion;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    StateDataLayout loadingDataLayout = StateDataLayout(
      isLoading: _isLoading,
      isError: _isError,
      isDataEmpty: _isEmpty,
      child: Container(
        child: Column(
          children: <Widget>[
            _currentQuestion != null
                ? QuestionPage(_currentQuestion,rightAnswerCallback: (answer) {

              Fluttertoast.showToast(
                msg: "恭喜你，回答正确",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
                backgroundColor: THEME_COLOR,
                textColor: Colors.white,
              );
              Future.delayed(Duration(milliseconds: 500)).then((data){

                Navigator.of(context).pop("success");

              });
            },wrongAnswerCallback: (wrong) {

              Fluttertoast.showToast(
                msg: "回答不正确",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIos: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
              );

              print("wrongAnswer");

            })
                : Text("")
          ],
        ),
      ),
      errorClick: () {
        _getRandomQuestion();
      },
    );
    return Scaffold(

      appBar: AppBar(
        title: Text(_currentQuestion!=null?_currentQuestion.title:"正在加载问题"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        actions: <Widget>[
          IconButton(
            splashColor: THEME_GREY_COLOR,
            icon: Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: () {

              setState(() {
                _getRandomQuestion();
              });
            },
          )
        ],
      ),
      body: loadingDataLayout,
    );
  }

  void _getRandomQuestion() {
    _currentQuestion=null;
    setState(() {
      _isLoading = true;
      _isError = false;
      _isEmpty = false;
      _title = "正在获取数据";
    });
    QuestionDataSource.getRandomQuestion(userId: null,callback: (question) {
      setState(() {
        _currentQuestion = question;
        _title = question.title;
        _isLoading = false;
        _isError = false;
        _isEmpty = false;
      });
    },errorCallback: (msg) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _isEmpty = false;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getRandomQuestion();
  }


  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

typedef GetQuestionSuccessCallback = void Function(QuestionBean question);
