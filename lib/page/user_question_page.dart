import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/UpdateUser.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/NoAdminQuestionBean.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'question_detail.dart';
import 'user_info_page.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';

class UserQuestionPage extends StatefulWidget {
  
  final String userId;
  final  String nickName;
  const UserQuestionPage(this.userId,this.nickName);
  @override
  _UserQuestionPageState createState() => _UserQuestionPageState();
}

class _UserQuestionPageState extends State<UserQuestionPage>
     {
  ScrollController _controller = new ScrollController();
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  bool _isNoMoreData = false;
  bool isPerformingRequest = true;
 

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
        userId: loginUser.id,
        createUserId:  widget.userId,
        count: 4, callback: (list) {
      print("size = ${list.length}");

      setState(() {
        isPerformingRequest = false;
        _isLoading = false;
        _currentPage = page;
        if (page == 1) {
          _noAdminQuestionList = list;
          if(_noAdminQuestionList.length==0){
            setState(() {
              _isEmpty = true;
            });
          }
        } else {
          list.forEach((question) {
            _noAdminQuestionList.add(question);
          });
          if (list.length > 0) {
            _isNoMoreData = false;
          } else {
            _isNoMoreData = true;
          }
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
                return QuestionDetailPage(question);
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
                          "提问人：${question.nickName}",
                          textAlign: TextAlign.start,
                        ),
                        GestureDetector(
                            onTap: () {
                              Navigator.of(context)
                                  .push(MaterialPageRoute(builder: (context) {
                                return UserInfoPage(
                                  userId: question.createUserId,
                                  nickName:question.nickName,
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
                                      image:  (BASE_FILE_URL + question.avatar),
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

  UserBean loginUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    UserDataSource.getLoginUser().then((user){
      loginUser = user;
      _getQuestionList(1);
    });

    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && !isPerformingRequest) {
        _getQuestionList((_currentPage + 1));
      }
    });
  }

 

  @override
  Widget build(BuildContext context) {

    LoadingDataLayout loadingDataLayout = LoadingDataLayout(
      isError: _isError,
      isLoading: _isLoading,
      isDataEmpty: _isEmpty,
      emptyTitle: "${widget.nickName}还没有提交过问题",
      errorClick: () {
        _getQuestionList(1);
      },
      dataWidget:_noAdminQuestionList.length>0?RefreshIndicator(
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
                    return   (_currentPage==1&&_noAdminQuestionList.length<4)?null:new Padding(
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
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                }
              }),
          onRefresh: () {
            _getQuestionList(1);
          }):null
    );
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.nickName}提交的问题"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: loadingDataLayout,

    );
  }

}
