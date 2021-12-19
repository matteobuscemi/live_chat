import 'package:flutter_demos/SocketIOChat/socket_utils.dart';

import 'user.dart';

class G {
  static List<User> dummyUsers;
  static User loggedInUser;
  static User toChatUser;
  static SocketUtils socketUtils;

  static void initDummyUsers() {
    User userA = User(id: 1000, name: 'A', email: 'testA@gmail.com');
    User userB = User(id: 1001, name: 'B', email: 'testB@gmail.com');
    dummyUsers = List();
    dummyUsers.add(userA);
    dummyUsers.add(userB);
  }

  static List<User> getUsersFor(User user) {
    List<User> filteredUsers = dummyUsers
        .where(
          (u) => (!u.name.toLowerCase().contains(
                user.name.toLowerCase(),
              )),
        )
        .toList();
    return filteredUsers;
  }

  static initSocket() {
    if (null == socketUtils) {
      socketUtils = SocketUtils();
    }
  }
}
