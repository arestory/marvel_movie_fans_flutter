
class ResponseBean<T>{


  String msg;

  String code;

  T data;


  ResponseBean.fromJsonMap(Map<String, dynamic> map):
        msg=map['msg'],
        code=map['code'],
        data=map['data'];

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> map = new Map<String, dynamic>();
    map['msg']=msg;
    map['code']=code;
    map['data']=data;
    return map;
  }
}