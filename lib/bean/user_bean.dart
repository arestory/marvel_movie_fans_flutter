//用户信息
class UserBean {

  String id;
  String nickName;
  String sex;
  int age;
  String slogan;
  String avatar;

  UserBean.fromJsonMap(Map<String, dynamic> map):
        id = map["id"],
        nickName = map["nickName"],
        sex = map["sex"],
        age = map["age"],
        slogan = map["slogan"],
        avatar = map["avatar"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['nickName'] = nickName;
    data['sex'] = sex;
    data['age'] = age;
    data['slogan'] = slogan;
    data['avatar'] = avatar;
    return data;
  }
}
//用户得分
class UserPoint {
  String userId;
  String nickName;
  String avatar;
  int point;

  UserPoint.fromJsonMap(Map<String, dynamic> map)
      : userId = map["userId"],
        nickName = map["nickName"],
        avatar = map["avatar"],
        point = map["point"];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['nickName'] = nickName;
    data['avatar'] = avatar;
    data['point'] = point;
    return data;
  }
}
//用户得分与排名
class UserPointRank extends UserPoint {

  int ranking;

  UserPointRank.fromJsonMap(Map<String, dynamic> map): super.fromJsonMap(map){
    ranking = map["ranking"];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = userId;
    data['nickName'] = nickName;
    data['avatar'] = avatar;
    data['point'] = point;
    data['ranking'] = ranking;
    return data;
  }
}
