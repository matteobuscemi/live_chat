import 'package:flutter/material.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'global.dart';
import 'user.dart';

class ChatUsersScreen extends StatefulWidget {
  ChatUsersScreen() : super();

  static const String ROUTE_ID = 'chat_users_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ChatUsersScreen> {
  List<User> _chatUsers;
  bool _connectedToSocket;
  String _connectMessage;

  @override
  void initState() {
    super.initState();
    _connectedToSocket = false;
    _connectMessage = 'Connecting...';
    _chatUsers = G.getUsersFor(G.loggedInUser);
    _connectToSocket();
  }

  _connectToSocket()async {
    print(
        'Connecting Logged In User ${G.loggedInUser.name}, ${G.loggedInUser.id}');
    G.initSocket();
    await G.socketUtils.initSocket(G.loggedInUser);
    G.socketUtils.connectToSocket();
    G.socketUtils.setOnConnectListener(onConnect);
    G.socketUtils.setOnConnectionErrorListener(onConnectionError);
    G.socketUtils.setOnConnectionTimeOutListener(onConnectionTimeout);
    G.socketUtils.setOnDisconnectListener(onDisconnect);
    G.socketUtils.setOnErrorListener(onError);
  }

  onConnect(data) {
    print('Connected $data');
    setState(() {
      _connectedToSocket = true;
    _connectMessage = 'Connected';
    });
  }
  onConnectionError(data) {
    print('onConnectionError $data');
    setState(() {
      _connectedToSocket = false;
    _connectMessage = 'Connection Error';
    });
  }
  onConnectionTimeout(data) {
    print('onConnectionTimeout $data');
    setState(() {
      _connectedToSocket = false;
    _connectMessage = 'Connection Timeout';
    });
  }
  onDisconnect(data) {
    print('onDisconnect $data');
    setState(() {
      _connectedToSocket = false;
    _connectMessage = 'Disconnected';
    });
  }
  onError(data) {
    print('onError $data');
    setState(() {
      _connectedToSocket = false;
    _connectMessage = 'Error';
    });
  }

  _openLoginScreen(context) async {
    await Navigator.pushReplacementNamed(context, LoginScreen.ROUTE_ID);
  }

  _openChatScreen(context) async {
    await Navigator.pushNamed(context, ChatScreen.ROUTE_ID);
  }

@override
  void dispose() {

    super.dispose();
    G.socketUtils.closeConnection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Festival Chat App Users"),
        actions: [
          IconButton(
              onPressed: () {
                
                _openLoginScreen(context);
              },
              icon: Icon(Icons.close))
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            Text(_connectedToSocket ? 'Connected' : _connectMessage),
            Expanded(
              child: ListView.builder(
                itemCount: _chatUsers.length,
                itemBuilder: (context, index) {
                  User user = _chatUsers[index];
                  return ListTile(
                    onTap: () {
                      G.toChatUser = user;
                      _openChatScreen(context);
                    },
                    title: Text(user.name),
                    subtitle: Text('ID ${user.id}, Email: ${user.email}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
