import 'package:flutter/material.dart';
import 'SocketIOChat/routes.dart';


void main(){
  runApp(HomeApp());
}

class HomeApp extends StatelessWidget {
  const HomeApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: Routes.routes(),
      initialRoute: Routes.initScreen(),
    );
  }
}