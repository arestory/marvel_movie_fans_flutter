import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';

class LoadingDataLayout extends StatefulWidget {
  final Widget child;
  final bool isLoading;
  final String loadingTitle;
  final String emptyTitle;
  final String errorTitle;

  final bool isDataEmpty;
  final bool isError;
  final VoidCallback errorClick;


   LoadingDataLayout(
      {Key key,
      this.child,
        this.loadingTitle:"正在加载中...",
        this.emptyTitle:"数据为空",
        this.errorTitle:"数据加载失败，点击重试",
      this.isLoading: true,
      this.isDataEmpty: false,
      this.isError: false,
      this.errorClick})
      : super(key: key);

  @override
  _LoadingDataLayoutState createState() => _LoadingDataLayoutState();
}

class _LoadingDataLayoutState extends State<LoadingDataLayout> {
  bool _isTapDown = false;

  Widget currentWidget() {
    if (widget.isLoading) {
      return Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(THEME_COLOR),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(widget.loadingTitle),
          )
        ],
      ));
    } else if (widget.isDataEmpty) {
      return Center(
          child: Column(
        //居中
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(Icons.receipt),
          Padding(
            padding: EdgeInsets.all(10),
            child: Text(widget.emptyTitle),
          )
        ],
      ));
    } else if (widget.isError) {
      return GestureDetector(
          onTapDown: (detail) {
            setState(() {
              _isTapDown = true;
            });
          },
          onTapUp: (detail) {
            setState(() {
              _isTapDown = false;
            });
          },
          onTap: widget.errorClick,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.signal_wifi_off,
                  color: _isTapDown ? THEME_COLOR : THEME_GREY_COLOR,
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    widget.errorTitle,
                    style: TextStyle(
                        color: _isTapDown ? THEME_COLOR : THEME_GREY_COLOR),
                  ),
                )
              ],
            ),
          ));
    } else {
      return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return currentWidget();
  }
}
