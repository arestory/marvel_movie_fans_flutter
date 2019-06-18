import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:marvel_movie_fans_flutter/bean/question_bean.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';

//import 'package:audioplayers/audioplayers.dart';
import 'package:marvel_movie_fans_flutter/widget/preview_photo.dart';

import 'commit_feedback_page.dart';

class Keyword {
  final String word;
  final int index;
  final bool selected;

  const Keyword(
    this.word,
    this.index,
    this.selected,
  );
}

class AnimItem {
  final AnimationController controller;
  final Animation<Color> animation;

  const AnimItem(this.controller, this.animation);
}

class QuestionPage extends StatefulWidget {
  final QuestionBean questionBean;
  final RightAnswerCallback rightAnswerCallback;
  final WrongAnswerCallback wrongAnswerCallback;

  const QuestionPage(this.questionBean,
      {this.rightAnswerCallback, this.wrongAnswerCallback});

  @override
  _QuestionPageState createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  List<Keyword> _currentAnswer = <Keyword>[];

  List<Keyword> _currentKeywords = <Keyword>[];

//  AudioPlayer _audioPlayer = new AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  String _getUserAnswer() {
    StringBuffer sb = new StringBuffer();
    _currentAnswer.forEach((word) {
      sb.write(word.word);
    });

    return sb.toString();
  }

  void _playSound() async {
//    await _audioPlayer.play("assets/audio/click.mp3", isLocal: true);
  }

//  List<Widget> _createAnswerViews() {
//    List<Widget> widgets = <Widget>[];
//    _currentAnswer.forEach((keyword) {
//      widgets.add(GestureDetector(
//          onTap: () {
//            clickKeyword(keyword);
//          },
//          child: Container(
//            color: keyword.word == "" ? THEME_GREY_COLOR : THEME_COLOR,
//            child: Center(
//              child: Text(
//                keyword.word,
//                textAlign: TextAlign.center,
//                style: TextStyle(color: Colors.white, fontSize: 20),
//              ),
//            ),
//          )));
//    });
//    return widgets;
//  }

  List<Widget> _createAnswerViews() {
    List<Widget> widgets = <Widget>[];
    _currentAnswer.forEach((keyword) {
      getAnimItem(keyword.index, answerAnimMap).controller.forward();
      widgets.add(AnimatedBuilder(
          animation: getAnimItem(keyword.index, answerAnimMap).animation,
          builder: (context, child) {
            return GestureDetector(
                onTap: () {
                  if (keyword.word != "") {
                    clickKeyword(keyword);
                  }
                },
                child: Container(
                  color:
                      getAnimItem(keyword.index, answerAnimMap).animation.value,
                  child: Center(
                    child: Text(
                      keyword.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ),
                ));
          }));
    });
    return widgets;
  }

  final Map<int, AnimItem> keywordAnimMap = new Map<int, AnimItem>();
  final Map<int, AnimItem> answerAnimMap = new Map<int, AnimItem>();

  AnimItem createAnimItem(Color startColor, Color endColor,
      {int duration: 200}) {
    AnimationController controller = new AnimationController(
        vsync: this, duration: Duration(milliseconds: duration));
    Animation<Color> animation =
        new ColorTween(begin: startColor, end: endColor).animate(controller);
    return new AnimItem(controller, animation);
  }

  AnimItem getAnimItem(int index, Map<int, AnimItem> map) {
    AnimItem item = map[index];
    if (item == null) {
      AnimItem newItem =
          createAnimItem(THEME_COLOR, THEME_GREY_COLOR, duration: 0);
      map[index] = newItem;
      return newItem;
    }
    return item;
  }

  List<Widget> _createKeywordViews() {
    List<Widget> widgets = <Widget>[];
    _currentKeywords.forEach((keyword) {
      getAnimItem(keyword.index, keywordAnimMap).controller.forward();
      widgets.add(AnimatedBuilder(
          animation: getAnimItem(keyword.index, keywordAnimMap).animation,
          builder: (context, widget) {
            return GestureDetector(
                onTap: () {
                  clickKeyword(keyword);
                },
                child: Container(
                  color: getAnimItem(keyword.index, keywordAnimMap)
                      .animation
                      .value,
                  child: Center(
                    child: Text(
                      keyword.word,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: keyword.selected ? Colors.white : THEME_COLOR,
                          fontSize: 16),
                    ),
                  ),
                ));
          }));
    });
    return widgets;
  }

//
//  List<Widget> _createKeywordViews() {
//    List<Widget> widgets = <Widget>[];
//    _currentKeywords.forEach((keyword) {
//      widgets.add(GestureDetector(
//          onTap: () {
//            clickKeyword(keyword);
//          },
//          child: Container(
//            color: keyword.selected ? THEME_COLOR : THEME_GREY_COLOR,
//            child: Center(
//              child: Text(
//                keyword.word,
//                textAlign: TextAlign.center,
//                style: TextStyle(
//                    color: keyword.selected ? Colors.white : THEME_COLOR,
//                    fontSize: 16),
//              ),
//            ),
//          )));
//    });
//    return widgets;
//  }

  void clickKeyword(Keyword keyword) {
    Keyword newKeyword =
        new Keyword(keyword.word, keyword.index, !keyword.selected);
    setState(() {
      if (keyword.selected) {
        int oldIndex = _currentAnswer.indexWhere((word) {
          return word.index == keyword.index;
        });
        _currentAnswer[oldIndex] = Keyword("", -1, false);
        _currentKeywords[keyword.index] = newKeyword;
        keywordAnimMap[keyword.index] =
            createAnimItem(THEME_COLOR, THEME_GREY_COLOR);
        answerAnimMap[keyword.index] =
            createAnimItem(THEME_COLOR, THEME_GREY_COLOR);
        _playSound();
      } else {
        int index = _currentAnswer.indexWhere((keyword) {
          return keyword.word == "";
        });
        if (index >= 0) {
          _playSound();
          keywordAnimMap[keyword.index] =
              createAnimItem(THEME_GREY_COLOR, THEME_COLOR);
          answerAnimMap[keyword.index] =
              createAnimItem(THEME_GREY_COLOR, THEME_COLOR);

          _currentAnswer[index] = newKeyword;
          _currentKeywords[keyword.index] = newKeyword;
          int lastIndex = _currentAnswer.lastIndexWhere((word) {
            return word.word == "";
          });
          if (lastIndex < 0) {
            if (_getUserAnswer() == widget.questionBean.answer) {
              if (widget.rightAnswerCallback != null) {
                widget.rightAnswerCallback(widget.questionBean.answer);
              }
            } else {
              if (widget.wrongAnswerCallback != null) {
                widget.wrongAnswerCallback(_getUserAnswer());
              }
            }
          }
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.questionBean.answer.split("").forEach((word) {
      _currentAnswer.add(Keyword("", -1, false));
    });
    int index = 0;
    widget.questionBean.keywords.split("").forEach((word) {
      _currentKeywords.add(Keyword(word, index++, false));
    });

    _initEnterAnim();
  }

  Animation<double> enterAnimation;
  AnimationController enterAnimController;
  double opacity = 0;
  Animation<double> roteAnimation;

  //初始化动画
  void _initEnterAnim() {
    enterAnimController = new AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    enterAnimation =
        new Tween(begin: 0.0, end: 1.0).animate(enterAnimController)
          ..addListener(() {
            setState(() {
              setState(() {
                opacity = enterAnimation.value;
              });
            });
          })
          ..addStatusListener((status) {
            print(status);
            if (status == AnimationStatus.completed) {
              //销毁动画
              enterAnimController.dispose();
            }
          });
    enterAnimController.forward();

    roteAnimation = new Tween(begin: 10.0, end: 20.0).animate(
        new AnimationController(
            duration: const Duration(milliseconds: 500), vsync: this))
      ..addListener(() {});
  }

  void seeAdv() async {
    //注册频道
    MethodChannel platform = MethodChannel('loginUser');
    //调用频道对应的方法,并获取返回值
    String result = await platform.invokeMethod('watchAdv');
    //也可以这么调用
    platform.invokeMethod("watchAdv").then((result) {});
  }

  void showToast() async {
    //注册频道
    MethodChannel platform = MethodChannel('loginUser');
    //调用频道对应的方法,并获取返回值
    String result = await platform.invokeMethod('showToast');
    //也可以这么调用
    platform.invokeMethod("showToast").then((result) {});
  }

  //根据答案长度设置对应的比例
  double getRatio() {
    if (_currentAnswer.length >= 4) {
      return 1.0;
    }
    if (_currentAnswer.length >= 3) {
      return 2.5;
    }

    return 3;
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

  void _showHelpDialog(BuildContext context) {
    Future<int> tipsCount = UserDataSource.getTipsCount();
    tipsCount.then((count) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return SimpleDialog(
              children: <Widget>[
                SimpleDialogOption(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('获取提示，今日剩余$count次'),
                  ),
                  onPressed: () {
                    if (Platform.isAndroid) {
                      String answer = widget.questionBean.answer;
                      //找到第一个空位置
                      int emptyPos = _currentAnswer.indexWhere((word) {
                        return word.word == "";
                      });
                      if (emptyPos >= 0) {
                        String key = answer.split("")[emptyPos];
                        int keyPos = _currentKeywords.indexWhere((word) {
                          return word.word == key;
                        });
                        UserDataSource.useTipsCount().then((enable) {
                          if (enable) {
                            setState(() {
                              _currentAnswer[emptyPos] =
                                  Keyword(key, keyPos, true);
                              _currentKeywords[keyPos] =
                                  Keyword(key, keyPos, true);
                            });
                          } else {
                            if (Platform.isAndroid) {
                              showDialog(
                                  context: context,
                                  barrierDismissible: true,
                                  builder: (context) {
                                    return AlertDialog(
                                        title: Text("今天次数已经用完,观看广告可增加提示次数哦"),
                                        actions: <Widget>[
                                          FlatButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: new Text("不用了",
                                                style: TextStyle(
                                                    color: THEME_GREY_COLOR)),
                                          ),
                                          FlatButton(
                                            onPressed: () {
                                              seeAdv();
                                            },
                                            child: new Text("去看",
                                                style: TextStyle(
                                                    color: THEME_COLOR)),
                                          )
                                        ]);
                                  });
                            } else {
                              _showToast("今天次数已经用完");
                            }
                          }
                        });
                      }
//                                      seeAdv();
                    }
                    Navigator.of(context).pop();
                  },
                ),
                SimpleDialogOption(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text('反馈问题'),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();

                    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                      return CommitFeedbackPage(
                        questionId: widget.questionBean.id,
                      );
                    }));
                  },
                ),
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Opacity(
      opacity: opacity,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  Navigator.of(context).push(PhotoView.previewPhoto(
                      context, BASE_FILE_URL + widget.questionBean.url));
                },
                child: Padding(
                  padding: EdgeInsets.all(5),
                  child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: FadeInImage.assetNetwork(
                          placeholder: "assets/images/loading.png",
                          image: BASE_FILE_URL + widget.questionBean.url,
                          fit: BoxFit.cover)
//              child: !_isEmpty&&!_isError&&!_isLoading?Image.network(_imgUrl):Image.asset("assets/images/loading.png"))

                      ),
                )),
            GridView.count(
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: _currentAnswer.length,
              shrinkWrap: true,
              crossAxisSpacing: 5,
              scrollDirection: Axis.vertical,
              padding: EdgeInsets.symmetric(horizontal: 10),
              childAspectRatio: getRatio(),
              children: _createAnswerViews(),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: GridView.count(
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 7,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                padding: EdgeInsets.symmetric(horizontal: 10),
                childAspectRatio: 1.0,
                children: _createKeywordViews(),
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: Center(
                  child: IconButton(
                      iconSize: 40,
                      alignment: Alignment.topCenter,
                      icon: Center(
                          child: Icon(
                        Icons.help,
                        color: THEME_COLOR,
                      )),
                      highlightColor: THEME_GREY_COLOR,
                      onPressed: () {
                        _showHelpDialog(context);
                      }),
                ))
          ],
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

typedef RightAnswerCallback = void Function(String answer);
typedef WrongAnswerCallback = void Function(String wrong);
