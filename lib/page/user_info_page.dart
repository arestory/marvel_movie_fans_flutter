import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/widget/PhotoView.dart';
class UserInfoPage extends StatefulWidget {
  final String userId;
  final String nickName;

  const UserInfoPage({this.userId, this.nickName});

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
        body: LoadingDataLayout(
          isError: _isError,
          isDataEmpty: _isEmpty,
          isLoading: _isLoading,
          errorClick: _getUserInfo,
          dataWidget: Column(
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
                         onTap: (){
                           Navigator.of(context).push(new PageRouteBuilder(
                               opaque: false,
                               pageBuilder: (BuildContext context, _, __) {
                                 return PhotoView(
                                   url: BASE_FILE_URL + currentUser.avatar,
                                 );
                               },
                               transitionsBuilder: (_,
                                   Animation<double> animation,
                                   __,
                                   Widget child) {
                                 return new FadeTransition(
                                   opacity: animation,
                                   child: new FadeTransition(
                                     opacity: new Tween<double>(
                                         begin: 0.5, end: 1.0)
                                         .animate(animation),
                                     child: child,
                                   ),
                                 );
                               }));
                         },
                         child:  Padding(
                           padding: EdgeInsets.only(left: 10,right: 10),
                           child: Container(
                             width: 60.0,
                             height: 60.0,
                             decoration: BoxDecoration(
                               color: THEME_COLOR,
                               shape: BoxShape.rectangle,
                               borderRadius: BorderRadius.circular(30.0),
                               image: DecorationImage(
                                 fit: BoxFit.cover,
                                 image: currentUser != null
                                     ? Image.network(
                                     BASE_FILE_URL + currentUser.avatar)
                                     .image
                                     : Image.asset(
                                     "assets/images/placeholder.png")
                                     .image,
                               ),
                             ),
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
              Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("昵称"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Text(widget.nickName),
                        ),
                      ],
                    ),
                  ),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ),
              Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("族群"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Text(
                              currentUser != null ? currentUser.sex : ""),
                        ),
                      ],
                    ),
                  ),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ),
              Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("年龄"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Text(currentUser != null
                              ? "${currentUser.age}"
                              : ""),
                        ),
                      ],
                    ),
                  ),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ),
              Padding(
                    padding: EdgeInsets.only(
                        top: 30, bottom: 30, left: 10, right: 10),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text("个性签名"),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 10,right: 10),
                          child: Text(currentUser != null
                              ? "${currentUser.slogan}"
                              : ""),
                        ),
                      ],
                    ),
                  ),
              Divider(
                height: 1,
                color: THEME_GREY_COLOR,
              ), InkWell(
                  radius: 1000,
                  splashColor: THEME_COLOR,
                  onTap: () {},
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
