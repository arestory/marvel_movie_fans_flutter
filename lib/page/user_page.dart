import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/UpdateUser.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/page/rank_page.dart';
import 'package:marvel_movie_fans_flutter/page/setting_page.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'about_page.dart';
import 'commit_feedback_page.dart';
import 'user_login_page.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/widget/PhotoView.dart';
import 'login_user_info_page.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';
import 'package:marvel_movie_fans_flutter/page/my_question_page.dart';
import 'package:marvel_movie_fans_flutter/util/page_route.dart';

class UserPage extends StatefulWidget {
  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with AutomaticKeepAliveClientMixin {
  UserBean loginUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    refreshUser();
    //监听用户登录结果
    eventBus.on<UserBean>().listen((user) {
      refreshUser();
    });

    eventBus.on<UpdateUserEvent>().listen((event) {
      setState(() {
        loginUser = event.userBean;
      });
    });

    //监听
    eventBus.on<String>().listen((eventNameValue) {
      if (eventNameValue == "exitLoginUser") {
        setState(() {
          loginUser = null;
        });
      }
    });
  }

  void getUserRanking() {
    UserDataSource.getUserRanking(loginUser.id,
        success: (point) {}, error: (msg) {});
  }

  void refreshUser() {
    UserDataSource.getLoginUser().then((user) {
      setState(() {
        print("刷新个人信息");
        loginUser = user;
        getUserRanking();
      });
    });
  }

  List<Widget> buildListView() {
    return <Widget>[
      GestureDetector(
          onTap: () {
            pushPage(context,
                    nextPage: loginUser != null
                        ? LoginUserInfoPage()
                        : UserLoginPage())
                .then((value) {
              if (value is String && value == "exitLoginUser") {
                loginUser = null;
              } else if (value is UserBean) {
                setState(() {
                  loginUser = value;
                });
              }
            });
          },
          child: Container(
            height: 200,
            color: THEME_COLOR,
            child: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          GestureDetector(
                              onTap: () {
                                pushPage(context,
                                        route: loginUser == null
                                            ? new MaterialPageRoute(
                                                builder: (context) {
                                                return UserLoginPage();
                                              })
                                            : new PageRouteBuilder(
                                                opaque: false,
                                                pageBuilder:
                                                    (BuildContext context, _,
                                                        __) {
                                                  return PhotoView(
                                                    url: BASE_FILE_URL +
                                                        loginUser.avatar,
                                                  );
                                                },
                                                transitionsBuilder: (_,
                                                    Animation<double> animation,
                                                    __,
                                                    Widget child) {
                                                  return new FadeTransition(
                                                    opacity: animation,
                                                    child: new FadeTransition(
                                                      opacity:
                                                          new Tween<double>(
                                                                  begin: 0.5,
                                                                  end: 1.0)
                                                              .animate(
                                                                  animation),
                                                      child: child,
                                                    ),
                                                  );
                                                }))
                                    .then((user) {
                                  if (user is UserBean) {
                                    setState(() {
                                      loginUser = user;
                                    });
                                  }
                                });
                                ;
                              },
                              child: Padding(
                                padding: EdgeInsets.only(left: 10),
                                child: Container(
                                  width: 50.0,
                                  height: 50.0,
                                  decoration: BoxDecoration(
                                      color: THEME_COLOR,
                                      shape: BoxShape.rectangle,
                                      border: Border.all(
                                          width: 1, color: Colors.white),
                                      borderRadius: BorderRadius.circular(25.0),
                                      image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: loginUser != null
                                              ? Image.network(BASE_FILE_URL +
                                                      loginUser.avatar)
                                                  .image
                                              : Image.asset(
                                                      "assets/images/placeholder.png")
                                                  .image)),
                                ),
                              )),
                          Padding(
                            padding: EdgeInsets.only(left: 10),
                            child: Text(
                              loginUser != null ? loginUser.nickName : "未登录",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 20),
                            ),
                          )
                        ],
                      ),
                    ),
                    IconButton(
                      splashColor: THEME_GREY_COLOR,
                      icon: Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        pushPage(context,
                                nextPage: loginUser != null
                                    ? LoginUserInfoPage()
                                    : UserLoginPage())
                            .then((value) {
                          if (value is String && value == "exitLoginUser") {
                            loginUser = null;
                          } else if (value is UserBean) {
                            setState(() {
                              loginUser = value;
                            });
                          }
                        });
                      },
                    )
                  ],
                )),
          )),
      InkWell(
        onTap: () {
          pushPage(context,
                  nextPage:
                      loginUser == null ? UserLoginPage() : MyQuestionPage())
              .then((user) {
            if (user is UserBean) {
              print("已登录 ${user.nickName}");
              loginUser = user;
            }
          });
        },
        radius: 1000,
        splashColor: THEME_COLOR,
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.edit,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "我的题目",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              ],
            )),
      ),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
        onTap: () {
          pushPage(context,
              nextPage: loginUser == null ? UserLoginPage() : RankPage());
//          Navigator.of(context).push(MaterialPageRoute(builder: (context) {
//            return loginUser == null ? UserLoginPage() : RankPage();
//          }));
        },
        radius: 1000,
        splashColor: THEME_COLOR,
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.language,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "排行榜",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              ],
            )),
      ),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
        onTap: () {

          pushPage(context, nextPage: SettingPage());

        },
        radius: 1000,
        splashColor: THEME_COLOR,
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.settings,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "设置",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              ],
            )),
      ),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
        onTap: () {
          pushPage(context, nextPage: CommitFeedbackPage());
        },
        radius: 1000,
        splashColor: THEME_COLOR,
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.email,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "反馈",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              ],
            )),
      ),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
      InkWell(
        onTap: () {
          pushPage(context, nextPage: AboutPage());
        },
        radius: 1000,
        splashColor: THEME_COLOR,
        child: Padding(
            padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),
            child: Row(
              children: <Widget>[
                Icon(
                  Icons.report,
                  color: Colors.black,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    "关于",
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                )
              ],
            )),
      ),
      Divider(
        height: 1,
        color: THEME_GREY_COLOR,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      child: Column(
        children: buildListView(),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
