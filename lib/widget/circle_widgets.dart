import 'package:flutter/material.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:marvel_movie_fans_flutter/util/api_constants.dart';



class CircleWidget extends StatefulWidget {
  final double radius;
  final Widget child;
  final Color backgroundColor;

  CircleWidget(this.radius, {this.backgroundColor,this.child});

  @override
  _CircleWidgetState createState() => _CircleWidgetState();
}

class _CircleWidgetState extends State<CircleWidget> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.radius),
      child: Container(
        color: widget.backgroundColor,
        width: widget.radius * 2,
        height: widget.radius * 2,
        child: widget.child,
      ),
    );
  }
}

class CirclePhoto extends StatelessWidget {
  final String url;
  final double height;
  final double width;

  const CirclePhoto({this.url, this.width: 40, this.height: 40});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: height,
      height: width,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(width / 2),
        child: FadeInImage.assetNetwork(
          image: url,
          placeholder: "assets/images/placeholder.png",
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
