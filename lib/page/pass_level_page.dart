import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/bean/event_bean.dart';
import 'package:marvel_movie_fans_flutter/widget/state_layout.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'level_question_list_page.dart';
import 'package:marvel_movie_fans_flutter/bean/user_bean.dart';
import 'user_login_page.dart';
import 'package:marvel_movie_fans_flutter/util/event_bus.dart';
class Level {
  final int level;
  final int count;
  final bool isFinish;

  const Level(this.level, {this.count, this.isFinish: false});
}

class LevelPassPage extends StatefulWidget {
  @override
  _LevelPassPageState createState() => _LevelPassPageState();
}

class _LevelPassPageState extends State<LevelPassPage>
    with AutomaticKeepAliveClientMixin {
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;

  UserBean loginUser;
  List<Level> levelList = <Level>[];

  void _getTotalQuestionCount() {
    setState(() {
      levelList.clear();
      _isLoading = true;
      _isEmpty = false;
      _isError = false;
    });
    QuestionDataSource.getQuestionCount(callback: (count) {
      setState(() {
        _isLoading = false;

        int levelIndex = 0;
        if (count > 0) {
          int countOfLastLevel = count % 10;
          for (int i = 1; i <= count; i++) {

            if (i != 0 &&  i % 10 == 0) {

              levelIndex++;
              if(loginUser!=null){
               UserDataSource.isLevelPass(loginUser.id,levelIndex).then((map){
                  var level = Level( map["level"], count: 10,isFinish: map["finish"]);
                  levelList.add(level);
                });
              }else{
                var level = Level(levelIndex, count: 10);
                levelList.add(level);
              }
            }
          }
          if (countOfLastLevel > 0) {

            if(loginUser!=null){
              UserDataSource.isLevelPass(loginUser.id,levelIndex+1).then((map){
                var level = Level( map["level"], count: 10,isFinish: map["finish"]);
                levelList.add(level);
              });
            }else{
              var level = Level(levelIndex+1, count: 10);
              levelList.add(level);
            }
          }
        } else {
          _isEmpty = true;
        }
      });
    }, errorCallback: (msg) {
      _getTotalQuestionCount();
    });
  }

  List<Widget> _createLevelWidget() {
    List<Widget> widgets = <Widget>[];

    levelList.forEach((level) {
      widgets.add(GestureDetector(
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) {
              return loginUser != null
                  ? LevelQuestionPage(level)
                  : UserLoginPage();
            })).then((value) {
              if (value is UserBean) {
                setState(() {
                  loginUser = value;
                });
              }
            });
          },
          child: CircleAvatar(
            backgroundColor: level.isFinish ? THEME_COLOR : THEME_GREY_COLOR,
            child: Center(
              child: Text(
                level.level.toString(),
                style: TextStyle(
                    color: level.isFinish ? Colors.white : THEME_COLOR),
              ),
            ),
          )));
    });

    return widgets;
  }

  void getLoginUser() {
    UserDataSource.getLoginUser().then((user) {
      setState(() {
        loginUser = user;
      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLoginUser();
    _getTotalQuestionCount();
    eventBus.on<Level>().listen((level){

      setState(() {

        levelList[level.level-1] = Level(level.level,count: level.count,isFinish: true);

        UserDataSource.savePassLevel(loginUser.id, level.level);
      });
    });

    //监听用户登录结果
    eventBus.on<UserBean>().listen((user){

      setState(() {

        loginUser = user;

        _getTotalQuestionCount();
      });
    });
    //监听用户修改个人信息
    eventBus.on<UpdateUserEvent>().listen((event){
      setState(() {
        loginUser = event.userBean;
      });
    });
    //监听
    eventBus.on<String>().listen((eventNameValue){

      if(eventNameValue=="exitLoginUser"){

        setState(() {

          loginUser = null;

          _getTotalQuestionCount();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return StateDataLayout(
      isError: _isError,
      isLoading: _isLoading,
      isDataEmpty: _isEmpty,
      child: Padding(
        padding: EdgeInsets.only(top: 10, bottom: 10),
        child: GridView.count(
          crossAxisCount: 5,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.symmetric(horizontal: 10),
          childAspectRatio: 1.0,
          children: _createLevelWidget(),
        ),
      ),
    );
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;
}
