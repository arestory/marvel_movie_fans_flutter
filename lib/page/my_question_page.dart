import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/user_bean.dart';
import 'package:marvel_movie_fans_flutter/bean/question_bean.dart';
import 'package:marvel_movie_fans_flutter/widget/state_layout.dart';
import 'package:marvel_movie_fans_flutter/widget/load_more_widget.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'upload_question_page.dart';

class MyQuestionPage extends StatefulWidget {
  @override
  _MyQuestionPageState createState() => _MyQuestionPageState();
}

class _MyQuestionPageState extends State<MyQuestionPage> {
//  ScrollController _controller = new ScrollController();
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  bool _isNoMoreData = false;
  bool isPerformingRequest = true;

  UserBean loginUser;

  int _currentPage = 1;
  List<NoAdminQuestionBean> _noAdminQuestionList = <NoAdminQuestionBean>[];

  void _getQuestionList(int page) {
    if (page == 1) {
      setState(() {
        _isLoading = true;
        _isEmpty = false;
        _isError = false;
      });
    }
    setState(() {
      isPerformingRequest = true;
    });

    QuestionDataSource.getNoAdminQuestion(page,
        auth: -1,
        createUserId: loginUser != null ? loginUser.id : null,
        userId: loginUser != null ? loginUser.id : null,
        count: 4, callback: (list) {
      print("size = ${list.length}");

      setState(() {
        isPerformingRequest = false;
        _isLoading = false;
        if (page == 1) {
          _noAdminQuestionList = list;
          if (_noAdminQuestionList.length == 0) {
            _isEmpty = true;
          }
        } else {
          list.forEach((question) {
            _noAdminQuestionList.add(question);
          });
        }
        if (list.length > 0) {
          _currentPage = page;
          _isNoMoreData = false;
        } else {
          _isNoMoreData = true;
        }
      });
    }, errorCallback: (msg) {
      print(msg);
      if (page == 1) {
        setState(() {
          _isNoMoreData = false;
          _isLoading = false;
          _isEmpty = false;
          _isError = true;
        });
      }
    });
  }

  Widget buildListItem(BuildContext context, int index) {
    if (index < _noAdminQuestionList.length) {
      NoAdminQuestionBean question = _noAdminQuestionList[index];
      return InkWell(
        radius: 1000,
        onTap: () {
//          Navigator.of(context).push(new PageRouteBuilder(
//              opaque: false,
//              pageBuilder: (BuildContext context, _, __) {
//                return QuestionDetailPage(question);
//              },
//              transitionsBuilder:
//                  (_, Animation<double> animation, __, Widget child) {
//                return new FadeTransition(
//                  opacity: animation,
//                  child: new FadeTransition(
//                    opacity: new Tween<double>(begin: 0.5, end: 1.0)
//                        .animate(animation),
//                    child: child,
//                  ),
//                );
//              }));
        },
        splashColor: THEME_COLOR,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 5),
              child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: FadeInImage.assetNetwork(
                      placeholder: "assets/images/loading.png",
                      image: BASE_FILE_URL + question.url,
                      fit: BoxFit.fitWidth)),
            ),
            Padding(
              padding: EdgeInsets.only(top: 10),
              child: Row(
                children: <Widget>[
                  Text(
                    "问题：${question.title}",
                    textAlign: TextAlign.start,
                  )
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.only(top: 10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Row(
                      children: <Widget>[
                        Text(
                          "答案：${question.answer}",
                          textAlign: TextAlign.start,
                        ),
                      ],
                    )),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        question.auth == 1 ? "已审核通过" : "待审核",
                        style: TextStyle(
                            color: question.auth == 1
                                ? THEME_COLOR
                                : THEME_GREY_COLOR),
                      ),
                    )
                  ],
                )),
            Divider(
              color: Colors.grey,
            )
          ],
        ),
      );
    }

    return null;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getLoginUser();
//    _controller.addListener(() {
//      var maxScroll = _controller.position.maxScrollExtent;
//      var pixels = _controller.position.pixels;
//      if (maxScroll == pixels && !isPerformingRequest) {
//        _getQuestionList((_currentPage + 1));
//      }
//    });
  }

  void getLoginUser() {
    UserDataSource.getLoginUser().then((user) {
      setState(() {
        loginUser = user;
        _getQuestionList(1);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    StateDataLayout loadingDataLayout = StateDataLayout(
      isError: _isError,
      isLoading: _isLoading,
      isDataEmpty: _isEmpty,
      emptyWidget: Center(
          child: Column(
            //居中
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.receipt),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("你还没有提交问题哦"),
              )
            ],
          )),
      errorClick: () {
        _getQuestionList(1);
      },
      child: RefreshIndicator(
          color: THEME_COLOR,
          notificationPredicate: (no) {
            return true;
          },
          child: LoadMoreWidget(
            itemCounts: _noAdminQuestionList.length,
            isNoMoreData: _isNoMoreData,
            loadMoreFinish: !isPerformingRequest,
            onLoadMore: (){
              _getQuestionList(_currentPage+1);
            },
            buildListItem: buildListItem,
          ),
//          child: ListView.builder(
//              scrollDirection: Axis.vertical,
//              controller: _controller,
//              itemBuilder: (BuildContext context, int index) {
//                if (index != _noAdminQuestionList.length) {
//                  return buildListItem(context, index);
//                } else {
//                  if (_isNoMoreData) {
//                    return new Padding(
//                      padding: const EdgeInsets.all(10.0),
//                      child: new Center(
//                        child: new Opacity(
//                          opacity: _isNoMoreData ? 1.0 : 0.0,
//                          child: Text("没有数据了"),
//                        ),
//                      ),
//                    );
//                  } else {
//                    return new Padding(
//                      padding: const EdgeInsets.all(10.0),
//                      child: new Center(
//                        child: Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            new CircularProgressIndicator(
//                              valueColor: AlwaysStoppedAnimation(THEME_COLOR),
//                            ),
//                            Padding(
//                              padding: EdgeInsets.all(10),
//                              child: Text("正在加载数据"),
//                            )
//                          ],
//                        ),
//                      ),
//                    );
//                  }
//                }
//              }),

          onRefresh: () {
            _getQuestionList(1);
          }),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("我的问题"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: THEME_COLOR,
          child: Icon(Icons.add, color: Colors.white),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return UploadQuestionPage();
            })).then((result) {
              if (result == "uploadNewQuestion") {
                _getQuestionList(1);
              }
            });
          }),
      body: loadingDataLayout,
    );
  }
}
