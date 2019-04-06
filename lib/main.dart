import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'layout/home.dart';
import 'layout/search2.dart';
import 'layout/search.dart';





Future main() async {

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);   /*yatay çevirmeyi kapatma*/

  runApp(new MaterialApp(
    title: "Marketim",
    theme: ThemeData(
      primaryColor: Colors.blue.shade800,
      accentColor: Colors.blue,
      canvasColor: Colors.white,
      
    ),
    //home: Home(),
    initialRoute: "/",
    routes: {
      "/":(context) => Home(),
      "/search2":(context) => Search2(),
      "/search":(context) => Search(),
    },
  ));
}  