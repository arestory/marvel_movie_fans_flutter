
class QuestionBean {

  String id;
  String title;
  String answer;
  String keywords;
  int point;
  int auth;
  String url;
  String type;
  String createUserId;
  String createTime;
  bool hadAnswer;

  QuestionBean.fromJsonMap(Map<String, dynamic> map):
        id = map["id"],
        title = map["title"],
        answer = map["answer"],
        keywords = map["keywords"],
        point = map["point"],
        auth = map["auth"],
        url = map["url"],
        type = map["type"],
        createUserId = map["createUserId"],
        createTime = map["createTime"],
        hadAnswer = map["hadAnswer"];

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
    return data;
  }
}


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