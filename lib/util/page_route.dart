import 'package:flutter/material.dart';


Future pushPage(BuildContext context,{StatefulWidget nextPage,Route route}){

 return  Navigator.of(context).push(route==null?MaterialPageRoute(builder: (_){

    return nextPage;
  }):route);

}


void pop(BuildContext context,{Object object}){

  Navigator.of(context).pop(object);
}