import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/QuestionBean.dart';
import 'common_question_page.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RandomPage extends StatefulWidget {

  final GetQuestionSuccessCallback questionSuccessCallback;

  const RandomPage(

      this.questionSuccessCallback
      );
  void refresh(){
    __randomPageState._getRandomQuestion();
  }
  static _RandomPageState __randomPageState = _RandomPageState();
  @override
  _RandomPageState createState() => __randomPageState;
}

class _RandomPageState extends State<RandomPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  String _title = "";

  QuestionBean _currentQuestion;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return LoadingDataLayout(
      isLoading: _isLoading,
      isError: _isError,
      isDataEmpty: _isEmpty,
      dataWidget: Container(
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
               _getRandomQuestion();
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
  }

  void _getRandomQuestion() {
    setState(() {
      _isLoading = true;
      _isError = false;
      _isEmpty = false;
      _title = "正在获取数据";
    });


    QuestionDataSource.getRandomQuestion(userId: null,callback: (question) {
      setState(() {
        _currentQuestion = question;
        widget.questionSuccessCallback(_currentQuestion);
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
