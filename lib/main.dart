import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'layout/home.dart';
import 'layout/json.dart';
import 'layout/hello.dart';
import 'layout/barcode.dart';




Future main() async {

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);   /*yatay çevirmeyi kapatma*/

  runApp(new MaterialApp(
    title: "Marketim",
    theme: ThemeData(
      primaryColor: Colors.blue.shade800
    ),
    //home: Home(),
    initialRoute: "/",
    routes: {
      "/":(context) => Home(),
      "/json":(context) => Json(),
      "/hello":(context) => TabsFabDemo(),
      "/barcode":(context) => Barcode(),
    },
  ));
}  