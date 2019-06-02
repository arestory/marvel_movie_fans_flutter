import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  String cacheSize = "清理缓存";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    int bytes = imageCache.currentSizeBytes;
    setState(() {
      cacheSize = "清理缓存:${(bytes/1024/1024).toStringAsFixed(2)}M";
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
  void _clearCache(){
    ImageCache imageCache = PaintingBinding.instance.imageCache;
    imageCache.clear();

    setState(() {

      cacheSize = "已清理完毕";
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
          title: Text("设置"),
        ),
        body: Column(
          children: <Widget>[
            InkWell(
                onTap: _clearCache,
                radius: 1000,
                splashColor: THEME_COLOR,
                child: Padding(
                    padding: EdgeInsets.only(left: 10, top: 20, bottom: 20),child: Container(

                  child: Row(

                    children: <Widget>[
                      Text("$cacheSize")

                    ],
                  ),
                ),)
            ),
            Divider(height:1,color: THEME_GREY_COLOR,)
          ],
        ));
  }
}
