import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/QuestionBean.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'common_question_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';

//import 'package:audioplayers/audioplayers.dart';
import 'package:marvel_movie_fans_flutter/widget/PhotoView.dart';
import 'pass_level_page.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';

class LevelQuestionPage extends StatefulWidget {
  final Level level;

  const LevelQuestionPage(this.level);

  @override
  _LevelQuestionPageState createState() => _LevelQuestionPageState();
}

class _LevelQuestionPageState extends State<LevelQuestionPage> {
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  List<QuestionBean> questionList = <QuestionBean>[];

  var _pageController = new PageController(initialPage: 0);
  String _title = "正在加载数据";
  int currentPage = 0;
  UserBean loginUser;

  void _getQuestionList() {
    QuestionDataSource.getQuestionList(widget.level.level,
        userId: loginUser != null ? loginUser.id : null, callback: (list) {
      setState(() {
        questionList.addAll(list);
        _title = questionList.first.title;
        _isLoading = false;
        //判断该关卡的题目是否全部答完
        if (!widget.level.isFinish) {
          bool existQuestionNotAnswer = questionList.any((question) {
            return !question.hadAnswer;
          });
          //如果所有问题已回答完毕
          if (!existQuestionNotAnswer) {
            eventBus.fire(widget.level);
          }
        }
      });
    }, errorCallback: (msg) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataSource.getLoginUser().then((user) {
      setState(() {
        if (user is UserBean) {
          setState(() {
            loginUser = user;
          });
        }
        _getQuestionList();
      });
    });
  }

  Widget buildItemWidget(BuildContext context, int index) {
    if (index >= questionList.length) {
      return null;
    }
    QuestionBean questionBean = questionList[index];

    if (questionBean != null) {
      return QuestionPage(
        questionBean,
        rightAnswerCallback: (answer) {
          if (!questionBean.hadAnswer) {
            UserDataSource.answerQuestion(loginUser.id, questionBean.id,
                success: (data) {
              print(data);
            }, fail: (msg) {
              print("fail $msg");
            });
            setState(() {
              questionBean.hadAnswer = true;
              questionList[index] = questionBean;
            });
          }
          if(index+1==questionList.length){


          int lastIndex =  questionList.indexWhere((question){

             return !question.hadAnswer;
           });
          if(lastIndex>=0){

            Fluttertoast.showToast(
              msg: "恭喜你，回答正确，请继续回答",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: THEME_COLOR,
              textColor: Colors.white,
            );
            Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
              _pageController.animateToPage(lastIndex,
                  duration: Duration(milliseconds: 200),
                  curve: ElasticInOutCurve(0.3));
            });
          }else{
            Fluttertoast.showToast(
              msg: "恭喜你，本关已全部回答完毕",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: THEME_COLOR,
              textColor: Colors.white,
            );

            Future.delayed(Duration(milliseconds: 500)).then((_){
              eventBus.fire(widget.level);
              Navigator.of(context).pop();
            });
          }

          }else{
            Fluttertoast.showToast(
              msg: "恭喜你，回答正确",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIos: 1,
              backgroundColor: THEME_COLOR,
              textColor: Colors.white,
            );
            Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
              _pageController.animateToPage(index + 1,
                  duration: Duration(milliseconds: 200),
                  curve: ElasticInOutCurve(0.3));
            });
          }

        },
        wrongAnswerCallback: (wrong) {
          Fluttertoast.showToast(
            msg: "回答不正确",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIos: 1,
            backgroundColor: Colors.grey,
            textColor: Colors.white,
          );
        },
      );
    }

    return null;
  }

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
        title: Text(_title),
      ),
      body: LoadingDataLayout(
        isError: _isError,
        isLoading: _isLoading,
        isDataEmpty: _isEmpty,
        errorClick: () {
          _getQuestionList();
        },
        dataWidget: Column(
          children: <Widget>[
            Expanded(
              child: PageView.builder(
                onPageChanged: (index) {
                  setState(() {
                    _title = questionList[index].title;
                    currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return buildItemWidget(context, index);
                },
                itemCount: questionList.length,
                controller: _pageController,
                scrollDirection: Axis.horizontal,
              ),
            ),
            questionList.length > 0
                ? Padding(
                    padding: EdgeInsets.all(20),
                    child: FlatButton(
                      color: THEME_COLOR,
                      splashColor: THEME_GREY_COLOR,
                      onPressed: () {
                        if (currentPage+1 == questionList.length) {

                          int lastIndex =  questionList.indexWhere((question){

                            return !question.hadAnswer;
                          });
                          if(lastIndex<0){

                            Fluttertoast.showToast(
                              msg: "恭喜你，本关已全部回答完毕",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: THEME_COLOR,
                              textColor: Colors.white,
                            );

                            Future.delayed(Duration(milliseconds: 500)).then((_){
                              eventBus.fire(widget.level);
                              Navigator.of(context).pop();
                            });
                          }else{

                            Fluttertoast.showToast(
                              msg: "恭喜你，回答正确，请继续回答",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIos: 1,
                              backgroundColor: THEME_COLOR,
                              textColor: Colors.white,
                            );
                            Future.delayed(Duration(milliseconds: 500)).whenComplete(() {
                              _pageController.animateToPage(lastIndex,
                                  duration: Duration(milliseconds: 200),
                                  curve: ElasticInOutCurve(0.3));
                            });
                          }
                        } else {
                          _pageController.jumpToPage(currentPage + 1);
                        }
                      },
                      child: Text(
                         currentPage+1==questionList.length?"完成": questionList[currentPage].hadAnswer ? "已回答，下一个":"下一个",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                : Text(""),
          ],
        ),
      ),
    );
  }
}
