import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:marvel_movie_fans_flutter/widget/loading_data_layout.dart';
import 'package:marvel_movie_fans_flutter/page/random_page.dart';
import 'package:marvel_movie_fans_flutter/bean/QuestionBean.dart';
import 'package:marvel_movie_fans_flutter/util/color_resource.dart';
import 'package:image_picker/image_picker.dart';
import 'package:marvel_movie_fans_flutter/page/pass_level_page.dart';
import 'package:marvel_movie_fans_flutter/page/no_admin_question_page.dart';
import 'package:marvel_movie_fans_flutter/page/user_page.dart';
import 'package:marvel_movie_fans_flutter/datasource/datasource.dart';
import 'package:marvel_movie_fans_flutter/bean/UserBean.dart';

void main() {
  runApp(MyApp());
  if (Platform.isAndroid) {
// 以下两行 设置android状态栏为透明的沉浸。写在组件渲染之后，是为了在渲染后进行set赋值，覆盖状态栏，写在渲染之前MaterialApp组件会覆盖掉这个值。
    SystemUiOverlayStyle systemUiOverlayStyle =
    SystemUiOverlayStyle(statusBarColor: Colors.transparent);
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '漫威猜影团',
      theme: ThemeData(
        primaryColor: THEME_COLOR,
          // This is the theme of your application.
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectIndex = 0;
  String _title = "正在加载问题";
  List<String> _titles = <String>["随机答题", "闯关问答", "问答圈", ""];
  List<Icon> _icons = <Icon>[
    Icon(
      Icons.casino,
      color: Colors.white,
    ),
    Icon(
      Icons.motorcycle,
      color: Colors.white,
    ),
    Icon(
      Icons.bubble_chart,
      color: Colors.white,
    ),
    Icon(
      Icons.person,
      color: Colors.white,
    )
  ];

  QuestionBean _questionBean;

  var _pageController = new PageController(initialPage: 0);

  void _changePage(int index) {
    setState(() {
      _selectIndex = index;
      _pageController.jumpToPage(_selectIndex);
      if (index != 0) {
        _title = _titles[index];
      } else {
        if (_questionBean != null) {
          _title = _questionBean.title;
        } else {
          _title = "正在加载问题";
        }
      }
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if(Platform.isAndroid){
       UserDataSource.forceSaveLoginUserFromLastNotFlutterVersion();
    }

  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    RandomPage randomPage = RandomPage((question) {
      setState(() {
        _questionBean = question;
        _title = _questionBean.title;
      });
    });
    return Scaffold(

      appBar:
      _selectIndex!=3?
      AppBar(
        leading: _icons[_selectIndex],
        actions: _selectIndex == 0
            ? <Widget>[
                IconButton(
                  splashColor: THEME_GREY_COLOR,
                  icon: Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    randomPage.refresh();
                    setState(() {
                      _title = "正在加载问题";
                    });
                  },
                )
              ]
            : null,
        elevation: 0,
        backgroundColor: THEME_COLOR,
        title: Text(_title),
      ):null,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        scrollDirection: Axis.horizontal,
        children: <Widget>[
          randomPage,
          LevelPassPage(),
          NoAdminQuestionPage(),
          UserPage(),
        ],
        controller: _pageController,
        onPageChanged: (index) {
          _changePage(index);
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.casino), title: Text("随机答题")),
          BottomNavigationBarItem(
              icon: Icon(Icons.motorcycle), title: Text("闯关问答")),
          BottomNavigationBarItem(
              icon: Icon(Icons.bubble_chart), title: Text("问答圈")),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text("我的")),
        ],
        currentIndex: _selectIndex,
        type: BottomNavigationBarType.fixed,
        unselectedItemColor: Colors.black,
        selectedItemColor: THEME_COLOR,
        onTap: (index) {
          _changePage(index);
        },
      ),
    );
  }
}
