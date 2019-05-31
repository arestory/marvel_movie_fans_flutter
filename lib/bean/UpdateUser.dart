import 'UserBean.dart';

class UpdateUserEvent{

 final UserBean userBean;
  final bool needToRefreshData;

  const UpdateUserEvent(this.userBean,this.needToRefreshData);

}