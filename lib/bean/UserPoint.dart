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
