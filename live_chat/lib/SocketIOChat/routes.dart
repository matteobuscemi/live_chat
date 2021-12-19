import '/SocketIOChat/chat_screen.dart';
import '/SocketIOChat/chat_users_screen.dart';
import '/SocketIOChat/login_screen.dart';
import '/main.dart';

class Routes {
  static routes() {
    return {
      LoginScreen.ROUTE_ID:(context) => LoginScreen(),
      ChatUsersScreen.ROUTE_ID:(context) => ChatUsersScreen(),
      ChatScreen.ROUTE_ID:(context) => ChatScreen(),
    };
  }

  static initScreen(){
    return LoginScreen.ROUTE_ID;
  }
}