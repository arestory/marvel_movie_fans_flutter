import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/user_bean.dart';
import 'package:marvel_movie_fans_flutter/page/user_question_page.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/widget/state_layout.dart';
import 'package:marvel_movie_fans_flutter/widget/circle_widgets.dart';
import 'package:marvel_movie_fans_flutter/widget/preview_photo.dart';

class UserInfoPage extends StatefulWidget {
  final String userId;
  final String nickName;
  final String avatar;

  const UserInfoPage({this.userId, this.nickName, this.avatar});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  UserBean currentUser;
  bool _isLoading = true;
  bool _isEmpty = false;
  bool _isError = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getUserInfo();
  }

  void _getUserInfo() {
    setState(() {
      _isLoading = true;
      _isEmpty = false;
      _isError = false;
    });
    UserDataSource.getUserInfo(widget.userId, success: (user) {
      setState(() {
        _isLoading = false;
        _isEmpty = false;
        _isError = false;
        currentUser = user;
      });
    }, fail: (msg) {
      setState(() {
        _isLoading = true;
        _isEmpty = false;
        _isError = false;
      });
    });
  }

  Widget _buildListItem({String title, String content}) {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 30, bottom: 30, left: 10, right: 10),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(title),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10, right: 10),
                child: Text(content),
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: THEME_GREY_COLOR,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          title: Text(widget.nickName),
        ),
        body: StateDataLayout(
          isError: _isError,
          isDataEmpty: _isEmpty,
          isLoading: _isLoading,
          errorClick: _getUserInfo,
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text("头像"),
                    ),
                    Row(
                      children: <Widget>[
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(PhotoView.previewPhoto(
                                context, BASE_FILE_URL + widget.avatar));
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: CirclePhoto(
                              url: BASE_FILE_URL + widget.avatar,
                              width: 60,
                              height: 60,
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ),
              _buildListItem(title: "昵称", content: widget.nickName),
              _buildListItem(
                  title: "族群",
                  content: currentUser != null ? currentUser.sex : ""),
              _buildListItem(
                  title: "年龄",
                  content: currentUser != null ? "${currentUser.age}" : ""),
              _buildListItem(
                  title: "个性签名",
                  content: currentUser != null ? "${currentUser.slogan}" : ""),
              InkWell(
                  radius: 1000,
                  splashColor: THEME_COLOR,
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return UserQuestionPage(
                          currentUser.id, currentUser.nickName);
                    }));
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("他/她提交的问题"),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 16, color: THEME_GREY_COLOR)
                      ],
                    ),
                  )),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ),
            ],
          ),
        ));
  }
}
