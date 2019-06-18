import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';

///让listView具备"上拉加载更多"的效果，只适用于水平方向的ListView
class LoadMoreWidget extends StatefulWidget {
  final VoidCallback onLoadMore;

  //加载完毕
  final bool loadMoreFinish;
  final bool isNoMoreData;
  final Widget noMoreDataFootView;
  final Widget loadMoreView;
  final IndexedWidgetBuilder buildListItem;
  final int itemCounts;

  const LoadMoreWidget(
      {this.buildListItem,
      this.itemCounts,
      this.noMoreDataFootView,
      this.loadMoreView,
      this.onLoadMore,
      this.isNoMoreData: false,
      this.loadMoreFinish: true});

  @override
  _LoadMoreWidgetState createState() => _LoadMoreWidgetState();
}

class _LoadMoreWidgetState extends State<LoadMoreWidget> {
  ScrollController _controller = new ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(() {
      if(widget.onLoadMore!=null){
        var maxScroll = _controller.position.maxScrollExtent;
        var pixels = _controller.position.pixels;
        if ((maxScroll == pixels && widget.loadMoreFinish)&&!widget.isNoMoreData) {
          print("滑到最底部了");
          widget.onLoadMore();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        scrollDirection: Axis.vertical,
        controller: _controller,
        itemBuilder: (BuildContext context, int index) {
          if (index != widget.itemCounts) {
            return widget.buildListItem(context, index);
          } else {
            
            if (widget.isNoMoreData) {
              return widget.noMoreDataFootView == null
                  ? new Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: new Center(
                        child: new Opacity(
                          opacity: widget.isNoMoreData ? 1.0 : 0.0,
                          child: Text("没有数据了"),
                        ),
                      ),
                    )
                  : widget.noMoreDataFootView;
            } else {
              return widget.loadMoreView == null
                  ? Opacity(
                      opacity: widget.loadMoreFinish ? 0 : 1,
                      child: new Padding(
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
                      ),
                    )
                  : widget.loadMoreView;
            }
          }
        });
  }
}
