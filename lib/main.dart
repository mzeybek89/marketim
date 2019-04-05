import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'layout/home.dart';
import 'layout/search4.dart';
import 'layout/search3.dart';
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
      "/search4":(context) => Search4(),
      "/search3":(context) => Search3(),
      "/search2":(context) => AutoComplete(),
      "/search":(context) => Search(),
    },
  ));
}  