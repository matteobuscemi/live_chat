import 'package:flutter/material.dart';
import 'package:flutter_demos/SocketIOChat/global.dart';
import 'package:flutter_demos/SocketIOChat/user.dart';
import '/SocketIOChat/chat_users_screen.dart';

class LoginScreen extends StatefulWidget {
  LoginScreen() : super();

  static const String ROUTE_ID = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController;
  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    G.initDummyUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Festival Chat App"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: _usernameController,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(6.0))),
                filled: true,
                fillColor: Colors.white,
                contentPadding: EdgeInsets.all(20.0),
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            OutlineButton(
                child: Text('Aanmelden'),
                onPressed: () {
                  _loginBtnTap();
                })
          ],
        ),
      ),
    );
  }

  _loginBtnTap() {
    if (_usernameController.text.isEmpty) {
      return;
    }
    User me = G.dummyUsers[0];
    if (_usernameController.text != 'a') {
      me = G.dummyUsers[1];
    }
    G.loggedInUser = me;
    _openChatUsersListScreen(context);
  }

  _openChatUsersListScreen(context) async {
    await Navigator.pushReplacementNamed(context, ChatUsersScreen.ROUTE_ID);
  }
}