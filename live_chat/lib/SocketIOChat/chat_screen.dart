import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_demos/SocketIOChat/chat_message_model.dart';
import 'package:flutter_demos/SocketIOChat/chat_title.dart';
import 'package:flutter_demos/SocketIOChat/socket_utils.dart';
import 'chat_screen.dart';
import 'login_screen.dart';
import 'global.dart';
import 'user.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen() : super();

  static const String ROUTE_ID = 'chat_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<ChatScreen> {
  List<ChatMessageModel> _chatMessages;
  User _toChatUser;
  UserOnlineStatus _userOnlineStatus;

  TextEditingController _chatTextController;
  ScrollController _chatListController;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }
  
  @override
  void dispose() {
    
    super.dispose();
    _removeListeners();
  }

  @override
  void initState() {
    super.initState();
    _chatMessages = List();
    _chatTextController = TextEditingController();
    _chatListController = ScrollController(initialScrollOffset: 0);
    _toChatUser = G.toChatUser;
    _userOnlineStatus = UserOnlineStatus.connecting;
    _initSocketListeners();
    _checkOnline();
  }

  _checkOnline() {
    ChatMessageModel chatMessageModel = ChatMessageModel(
      chatId: 0,
      to: _toChatUser.id,
      from: G.loggedInUser.id,
      toUserOnlineStatus: false,
      message: '',
      chatType: SocketUtils.SINGLE_CHAT,
    );
    G.socketUtils.checkOnline(chatMessageModel);
  }

  _initSocketListeners() async {
    G.socketUtils.setOnChatMessageReceiveListener(onChatMessageReceived);
    G.socketUtils.setOnlineUserStatusListener(onUserStatus);
  }

  _removeListeners() async {
    G.socketUtils.setOnChatMessageReceiveListener(null);
    G.socketUtils.setOnlineUserStatusListener(null);
  }

  onUserStatus(data) {
    print('onUserStatus $data');
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    setState(() {
      _userOnlineStatus = chatMessageModel.toUserOnlineStatus
          ? UserOnlineStatus.online
          : UserOnlineStatus.not_online;
    });
  }

  onChatMessageReceived(data) {
    print('onChatMessageReceived $data');
    ChatMessageModel chatMessageModel = ChatMessageModel.fromJson(data);
    chatMessageModel.isFromMe = false;
    processMessage(chatMessageModel);
    _chatListScrollToBottom();
  }

  processMessage(chatMessageModel) {
    setState(() {
      _chatMessages.add(chatMessageModel);
    });
  }

  _chatListScrollToBottom() {
    Timer(Duration(milliseconds: 100), () {
      if (_chatListController.hasClients) {
        _chatListController.animateTo(
            _chatListController.position.maxScrollExtent,
            duration: Duration(milliseconds: 100),
            curve: Curves.decelerate);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ChatTitle(
            toChatUser: _toChatUser, userOnlineStatus: _userOnlineStatus),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(30),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                controller: _chatListController,
                itemCount: _chatMessages.length,
                itemBuilder: (context, index) {
                  ChatMessageModel chatMessageModel = _chatMessages[index];
                  bool fromMe = chatMessageModel.isFromMe;
                  return Container(
                    padding: EdgeInsets.all(20),
                    margin: EdgeInsets.all(10.0),
                    alignment:
                        fromMe ? Alignment.centerRight : Alignment.centerLeft,
                    color: fromMe ? Colors.green : Colors.grey,
                    child: Text(chatMessageModel.message),
                  );
                },
              ),
            ),
            _bottomChatArea(),
          ],
        ),
      ),
    );
  }

  _bottomChatArea() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          _chatTextArea(),
          IconButton(
              onPressed: () {
                _sendMessageBtnTap();
              },
              icon: Icon(Icons.send))
        ],
      ),
    );
  }

  _sendMessageBtnTap() async {
    if (_chatTextController.text.isEmpty) {
      return;
    }
    ChatMessageModel chatMessageModel = ChatMessageModel(
      chatId: 0,
      to: _toChatUser.id,
      from: G.loggedInUser.id,
      toUserOnlineStatus: false,
      message: _chatTextController.text,
      chatType: SocketUtils.SINGLE_CHAT,
      isFromMe: true,
    );
    processMessage(chatMessageModel);
    G.socketUtils.sendSingleChatMessage(chatMessageModel);
    _chatListScrollToBottom();
  }

  _chatTextArea() {
    return Expanded(
      child: TextField(
        controller: _chatTextController,
        decoration: InputDecoration(
          enabledBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          focusedBorder:
              OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.all(10),
          hintText: "Schrijf een bericht",
        ),
      ),
    );
  }
}
