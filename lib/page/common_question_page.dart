import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvel_movie_fans_flutter/bean/QuestionBean.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';

//import 'package:audioplayers/audioplayers.dart';
import 'package:marvel_movie_fans_flutter/widget/PhotoView.dart';

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
    with AutomaticKeepAliveClientMixin {
  List<Keyword> _currentAnswer = <Keyword>[];

  List<Keyword> _currentKeywords = <Keyword>[];

//  AudioPlayer _audioPlayer = new AudioPlayer(mode: PlayerMode.LOW_LATENCY);

  bool _tapHelp = false;

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

  List<Widget> _createAnswerViews() {
    List<Widget> widgets = <Widget>[];
    _currentAnswer.forEach((keyword) {
      widgets.add(GestureDetector(
          onTap: () {
            if (keyword.word != "") {
              _playSound();
              setState(() {
                int oldIndex = _currentAnswer.indexOf(keyword);
                _currentAnswer[oldIndex] = Keyword("", -1, false);
                Keyword newKeyword =
                    new Keyword(keyword.word, keyword.index, false);

                _currentKeywords[keyword.index] = newKeyword;
              });
            }
          },
          child: Container(
            color: keyword.word == "" ? THEME_GREY_COLOR : THEME_COLOR,
            child: Center(
              child: Text(
                keyword.word,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
          )));
    });
    return widgets;
  }

  List<Widget> _createKeywordViews() {
    List<Widget> widgets = <Widget>[];

    _currentKeywords.forEach((keyword) {
      widgets.add(GestureDetector(
          onTap: () {
            Keyword newKeyword =
                new Keyword(keyword.word, keyword.index, !keyword.selected);
            print("onTap");
            setState(() {
              if (keyword.selected) {
                int oldIndex = _currentAnswer.indexOf(keyword);
                _currentAnswer[oldIndex] = Keyword("", -1, false);
                _currentKeywords[keyword.index] = newKeyword;

                _playSound();
              } else {
                int index = _currentAnswer.indexWhere((keyword) {
                  return keyword.word == "";
                });
                if (index >= 0) {
                  _playSound();

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
          },
          child: Container(
            color: keyword.selected ? THEME_COLOR : THEME_GREY_COLOR,
            child: Center(
              child: Text(
                keyword.word,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: keyword.selected ? Colors.white : THEME_COLOR,
                    fontSize: 16),
              ),
            ),
//          onTapUp: (d){
//            print("onTapUp");
//
//          },
          )));
    });
    return widgets;
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
  }

  void _showMenu() async {
    final result = await showMenu(
        context: context,
        position: RelativeRect.fromLTRB(400.0, 700.0, 100.0, 100.0),
//    position: RelativeRect.fromLTRB(1000.0, 1000.0, 0.0, 10.0),
        items: <PopupMenuItem<String>>[
          new PopupMenuItem<String>(value: '获取提示', child: new Text('获取提示')),
          new PopupMenuItem<String>(value: '反馈问题', child: new Text('反馈问题')),
        ]);
  }

  void seeAdv() async{

    MethodChannel platform = MethodChannel('loginUser');
    //第一个参数 tryToast为Java/oc中的方法名(后面会讲)，第二个参数数组为传参数组
    String user = await platform.invokeMethod('seeAdv');
  }

  double getRatio() {
    if (_currentAnswer.length >= 4) {
      return 1.0;
    }
    if (_currentAnswer.length >= 3) {
      return 2.5;
    }

    return 3;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          GestureDetector(
              onTap: () {
                Navigator.of(context).push(new PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (BuildContext context, _, __) {
                      return PhotoView(
                        url: BASE_FILE_URL + widget.questionBean.url,
                      );
                    },
                    transitionsBuilder:
                        (_, Animation<double> animation, __, Widget child) {
                      return new FadeTransition(
                        opacity: animation,
                        child: new FadeTransition(
                          opacity: new Tween<double>(begin: 0.5, end: 1.0)
                              .animate(animation),
                          child: child,
                        ),
                      );
                    }));
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
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              children: <Widget>[
                                SimpleDialogOption(
                                  child: Padding(
                                    padding: EdgeInsets.all(10),
                                    child: Text('获取提示'),
                                  ),
                                  onPressed: () {
                                    if (Platform.isAndroid) {
                                      seeAdv();

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
                                  },
                                ),
                              ],
                            );
                          });
                    }),
              ))
        ],
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}

typedef RightAnswerCallback = void Function(String answer);
typedef WrongAnswerCallback = void Function(String wrong);
