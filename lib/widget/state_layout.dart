import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';

///状态布局，用于统一控制加载数据效果、加载异常、空数据等页面效果
class StateDataLayout extends StatefulWidget {
  final Widget child;
  final Widget loadingWidget;
  final Widget emptyWidget;
  final Widget errorWidget;
  final bool isLoading;

  final bool isDataEmpty;
  final bool isError;
  final VoidCallback errorClick;

  StateDataLayout(
      {Key key,
      this.child,
      this.emptyWidget,
      this.loadingWidget,
      this.errorWidget,
      this.isLoading: true,
      this.isDataEmpty: false,
      this.isError: false,
      this.errorClick})
      : super(key: key);

  @override
  _StateDataLayoutState createState() => _StateDataLayoutState();
}

class _StateDataLayoutState extends State<StateDataLayout>
    {
  bool _isTapDown = false;
  final String _loadingTitle = "正在加载中...",
      _emptyTitle = "数据为空",
      _errorTitle = "数据加载失败，点击重试";



  Widget currentWidget() {
    if (widget.isLoading) {
      return widget.loadingWidget == null
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(THEME_COLOR),
                ),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(_loadingTitle),
                )
              ],
            ))
          : widget.loadingWidget;
    } else if (widget.isDataEmpty) {
      return widget.emptyWidget == null
          ? Center(
              child: Column(
              //居中
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.receipt),
                Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(_emptyTitle),
                )
              ],
            ))
          : widget.emptyWidget;
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
          child: widget.errorWidget == null
              ? Center(
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
                          _errorTitle,
                          style: TextStyle(
                              color:
                                  _isTapDown ? THEME_COLOR : THEME_GREY_COLOR),
                        ),
                      )
                    ],
                  ),
                )
              : widget.errorWidget);
    } else {

      return widget.child;
    }
  }

  @override
  Widget build(BuildContext context) {
    return currentWidget();
  }
}
