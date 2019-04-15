import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:async_resource/file_resource.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'layout/home.dart';
import 'layout/search2.dart';
import 'layout/search.dart';
import 'layout/maps.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:location/location.dart' as loc;

DatabaseHelper databaseHelper = DatabaseHelper();

  Future LocationInfo() async{
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    loc.Location location = new loc.Location(); 
    loc.LocationData currentLocation;
    double lat,lng;
    await location.changeSettings(
      accuracy: loc.LocationAccuracy.HIGH,
      interval: 1000,
    );  
    try {
      currentLocation = await location.getLocation();      
      lat = currentLocation.latitude;
      lng = currentLocation.longitude;
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //error = 'Permission denied';
      } 
      lat = 0;
      lng = 0;
    }
     await databaseHelper.addKonum(lat, lng,51);

  }


Future main() async {

  LocationInfo();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);   /*yatay çevirmeyi kapatma*/

  /*final path = (await getApplicationDocumentsDirectory()).path;

  final myDataResource = HttpNetworkResource<List>(
    url: 'http://zeybek.tk/api/liste.php?s=0&all=true',
    //parser: (contents) => List.fromJson(contents),
    cache: FileResource(File('$path/urunler.json')),
    maxAge: Duration(minutes: 60),
    strategy: CacheStrategy.cacheFirst,
  );

  myDataResource.get();*/

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
      "/maps":(context)=>Maps(),
 
    },
  ));
}  