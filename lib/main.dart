import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'layout/home.dart';
import 'layout/search.dart';
import 'layout/maps.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:location/location.dart' as loc;
import 'package:Marketim/layout/test/longpress.dart';

DatabaseHelper databaseHelper = DatabaseHelper();

  Future LocationInfo() async{
    double lat,lng;
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();
    loc.Location location = new loc.Location();
    await location.requestPermission(); 
    bool izin = await location.hasPermission();
    if(izin==false){
        lat = 38.467866199999996;
        lng =  27.2184286;

        databaseHelper.getCountKonum().then((sayi){
          if(sayi==0)
          {
            databaseHelper.addKonum(lat, lng,51); // sadece 1 kere kayıt oluştur
          }
        });
    }
    else{
        loc.LocationData currentLocation;    
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
        
        }
        databaseHelper.getCountKonum().then((sayi){
          if(sayi==0)
          {
          databaseHelper.addKonum(lat, lng,51); // sadece 1 kere kayıt oluştur
          }
        });
    }
    

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
      "/search":(context) => Search(),
      "/maps":(context)=>Maps(),
      "/test":(context) => Page(),
 
    },
  ));
}  