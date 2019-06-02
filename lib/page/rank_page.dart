import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/bean/UserPointRank.dart';
import 'package:marvel_movie_fans_flutter/page/user_info_page.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserPoint.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';

class RankPage extends StatefulWidget {
  @override
  _RankPageState createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> {
  ScrollController _controller = new ScrollController();
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;
  bool _isNoMoreData = false;
  bool isPerformingRequest = false;

  int _currentPage = 1;

  List<UserPoint> userPoints = <UserPoint>[];

  UserBean loginUser;
  UserPointRank userPointRank;
  void getUserRanking(){

    UserDataSource.getUserRanking(loginUser.id,success:(point){

      setState(() {
        userPointRank=point;
      });
    },error: (msg){

    });
  }
  void _getUserPoint(int page) {
    if (page == 1) {
      _changeStatus(isLoading: true);
    }
    setState(() {
      isPerformingRequest = true;
    });
    UserDataSource.getUserPoint(page, success: (list) {
      _changeStatus();
      setState(() {
        isPerformingRequest = false;
        _currentPage = page;

        if (list.isEmpty) {
          _isNoMoreData = true;
        } else {
          list.forEach((point) {
            userPoints.add(point);
          });
        }
      });
    }, error: (msg) {
      if (page == 1) {
        _changeStatus(isError: true);
        setState(() {
          isPerformingRequest = false;
        });
      } else {}
    });
  }

  void _changeStatus(
      {bool isLoading: false, bool isEmpty: false, bool isError: false}) {
    setState(() {
      _isLoading = isLoading;
      _isEmpty = isEmpty;
      _isError = isError;
    });
  }

  Widget buildItem(BuildContext context, int index) {
    if (index >= userPoints.length) {
      return null;
    }
    if(index==0&&userPointRank!=null){


      return  Column(

        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 10,top: 20,bottom: 20),
            child: Row(

              children: <Widget>[
                Expanded(child:
                Row(children: <Widget>[

                  Padding(
                    padding: EdgeInsets.only(left: 30,right: 10),
                    child: Container(
                      width: 50.0,
                      height: 50.0,
                      decoration: BoxDecoration(
                        color: THEME_COLOR,
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.circular(25.0),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: FadeInImage.assetNetwork(
                            image: BASE_FILE_URL + loginUser.avatar,
                            placeholder: "assets/images/placeholder.png",
                            fit: BoxFit.cover,
                          ).image,
                        ),
                      ),
                    ),
                  ),

                  Padding(padding: EdgeInsets.all(5),child: Text("你的得分：${userPointRank.point}",style: TextStyle(fontSize: 20,color: THEME_COLOR ,)),)
                ],),),   Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Text("第${userPointRank.ranking}名",style: TextStyle(fontSize: 20,color: THEME_COLOR),),
                ),

              ],
            ),

          ),
          Divider(height: 0,color: THEME_GREY_COLOR,)
        ],
      );

    }
    UserPoint userPoint = userPoints[userPointRank!=null?(index-1):index];

    return InkWell(
        onTap: () {


          Navigator.of(context).push(MaterialPageRoute(builder: (context){


            return UserInfoPage(userId: userPoint.userId,nickName: userPoint.nickName);
          }));
        },
        splashColor: THEME_COLOR,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Row(
                  children: <Widget>[
                    Text("${index}",style: TextStyle(fontSize: 20),),
                    Padding(
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
                              image: BASE_FILE_URL + userPoint.avatar,
                              placeholder: "assets/images/placeholder.png",
                              fit: BoxFit.cover,
                            ).image,
                          ),
                        ),
                      ),
                    ), Padding(padding: EdgeInsets.only(left: 10),child: Text("${userPoint.nickName}"),),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(10),
                child: Text("${userPoint.point}",style: TextStyle(fontSize: 20,color: index<10?THEME_COLOR:Colors.grey,fontStyle: FontStyle.italic),),
              ),
            ],
          ),
        ));
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      var maxScroll = _controller.position.maxScrollExtent;
      var pixels = _controller.position.pixels;
      if (maxScroll == pixels && !isPerformingRequest) {
        _getUserPoint((_currentPage + 1));
      }
    });
    UserDataSource.getLoginUser().then((user){

      if(user is UserBean){

        setState(() {
          loginUser = user;
          getUserRanking();
        });
      }
    });
    _getUserPoint(1);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("排行榜"),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            }),
      ),
      body: LoadingDataLayout(
        isLoading: _isLoading,
        isDataEmpty: _isEmpty,
        isError: _isError,
        dataWidget: RefreshIndicator(
          onRefresh: () {
            _getUserPoint(1);
          },
          color: THEME_COLOR,
          notificationPredicate: (no) {
            return true;
          },
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              controller: _controller,
              itemBuilder: (context, index) {
                if (index != userPoints.length) {
                  return buildItem(context, index);
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
        ),
      ),
    );
  }
}
