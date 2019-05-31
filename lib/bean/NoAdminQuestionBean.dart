
import 'QuestionBean.dart';
class NoAdminQuestionBean extends  QuestionBean{

  String nickName;
  String avatar;

  NoAdminQuestionBean.fromJsonMap(Map<String, dynamic> map) : super.fromJsonMap(map){

    nickName = map["nickName"];
    avatar = map["avatar"];
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['title'] = title;
    data['answer'] = answer;
    data['keywords'] = keywords;
    data['point'] = point;
    data['auth'] = auth;
    data['url'] = url;
    data['type'] = type;
    data['createUserId'] = createUserId;
    data['createTime'] = createTime;
    data['hadAnswer'] = hadAnswer;
    data['nickName'] = hadAnswer;
    data['avatar'] = hadAnswer;
    return data;
  }

}