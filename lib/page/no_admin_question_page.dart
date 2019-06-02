import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/UpdateUser.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/page/user_login_page.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/NoAdminQuestionBean.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'question_detail.dart';
import 'user_info_page.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';

class NoAdminQuestionPage extends StatefulWidget {
  @override
  _NoAdminQuestionPageState createState() => _NoAdminQuestionPageState();
}

class _NoAdminQuestionPageState extends State<NoAdminQuestionPage>
    with AutomaticKeepAliveClientMixin {
  ScrollController _controller = new ScrollController();
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
        userId: loginUser != null ? loginUser.id : null,
        count: 4, callback: (list) {
      print("size = ${list.length}");

      setState(() {
        isPerformingRequest = false;
        _isLoading = false;
        if (page == 1) {
          _noAdminQuestionList = list;
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
          Navigator.of(context).push(new PageRouteBuilder(
              opaque: false,
              pageBuilder: (BuildContext context, _, __) {
                return loginUser!=null?QuestionDetailPage(question):UserLoginPage();
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
              })).then((question){
                if(question is NoAdminQuestionBean){

                  int index = _noAdminQuestionList.indexOf(question);
                  if(index>=0){
                    question.hadAnswer = true;
                    setState(() {
                      _noAdminQuestionList[index] =question;

                    });
                  }

                }
          });
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
                          (loginUser != null &&
                              loginUser.id ==
                                  question.createUserId)? "提问人：${loginUser.nickName}":"提问人：${question.nickName}",
                          textAlign: TextAlign.start,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return UserInfoPage(
                                  userId: question.createUserId,
                                  nickName: (loginUser != null &&
                                      loginUser.id ==
                                          question.createUserId)?loginUser.nickName: question.nickName,
                                );
                              }));
                            },
                            child: Padding(
                              padding: EdgeInsets.only(left: 10),
                              child: Container(
                                width: 40.0,
                                height: 40.0,
                                decoration: BoxDecoration(
                                  color: THEME_COLOR,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(20.0),
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: FadeInImage.assetNetwork(
                                      image: (loginUser != null &&
                                              loginUser.id ==
                                                  question.createUserId)
                                          ? (BASE_FILE_URL + loginUser.avatar)
                                          : (BASE_FILE_URL + question.avatar),
                                      placeholder:
                                          "assets/images/placeholder.png",
                                      fit: BoxFit.cover,
                                    ).image,
                                  ),
                                ),
                              ),
                            ))
                      ],
                    )),
                    Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: Text(
                        question.hadAnswer ? "已回答此问题" : "未回答",
                        style: TextStyle(
                            color: question.hadAnswer
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
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && !isPerformingRequest) {
        _getQuestionList((_currentPage + 1));
      }
    });
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
    super.build(context);
    //监听用户登录结果
    eventBus.on<UserBean>().listen((user) {
      setState(() {
        loginUser = user;
        _getQuestionList(1);
      });
    });

    eventBus.on<UpdateUserEvent>().listen((event){
      setState(() {
        loginUser = event.userBean;
      });
    });
    //监听
    eventBus.on<String>().listen((eventNameValue) {
      if (eventNameValue == "exitLoginUser") {
        setState(() {
          loginUser = null;
          _getQuestionList(1);
        });
      }
    });
    LoadingDataLayout loadingDataLayout = LoadingDataLayout(
      isError: _isError,
      isLoading: _isLoading,
      isDataEmpty: _isEmpty,
      errorClick: () {
        _getQuestionList(1);
      },
      dataWidget: RefreshIndicator(
          color: THEME_COLOR,
          notificationPredicate: (no) {
            return true;
          },
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _controller,
              itemBuilder: (BuildContext context, int index) {
                if (index != _noAdminQuestionList.length) {
                  return buildListItem(context, index);
                } else {
                  if (_isNoMoreData) {
                    return new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Center(
                        child: new Opacity(
                          opacity: _isNoMoreData ? 1.0 : 0.0,
                          child: Text("没有数据了"),
                        ),
                      ),
                    );
                  } else {
                    return new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            new CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(THEME_COLOR),
                            ),
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text("正在加载数据"),
                            )
                          ],
                        ),
                      ),
                    );
                  }
                }
              }),
          onRefresh: () {
            _getQuestionList(1);
          }),
    );
    return loadingDataLayout;
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
