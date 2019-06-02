import 'UserPoint.dart';
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
