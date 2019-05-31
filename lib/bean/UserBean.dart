
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
