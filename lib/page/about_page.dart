import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info/package_info.dart';

class AboutPage extends StatefulWidget {
  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String version = "1.0.0";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      setState(() {
        version = info.version;
      });
    });
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
          title: Text("关于"),
        ),
        body: Container(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 40),
            child: Column(
              children: <Widget>[
                Center(
                    child: Container(
                  height: 100,
                  width: 100,
                  child: Image.asset("assets/images/app_logo_round.png"),
                )),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "V$version",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "这是一款基于漫威背景的猜电影APP，检验你是不是一个合格的漫威真爱粉！用户也可以添加新的问题，在审核通过后，提交的问题将会出现在问答圈，与大家一起分享猜影的快乐！",
                      style: TextStyle(
                        fontSize: 20,
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
