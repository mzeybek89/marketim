import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';


class Marketler extends StatefulWidget {
  Marketler({Key key}) : super(key: key);
  

  @override
  _MarketlerPageState createState() => new _MarketlerPageState();
}

class _MarketlerPageState extends State<Marketler> {
  var f = new NumberFormat("##.0", "tr_TR");
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  var marketler = List<Yerler>();
  bool _progress = true;
  

  @override
  void initState() {
    super.initState();
    LocationInfo();
  }

  kmTomt(double distance){
    double newVal = distance;
    String ret; 
    if(distance<1){
      newVal = distance*1000;
      ret = f.format(newVal)+" m";
    }
    else{
      ret = f.format(newVal)+" km";
    }
    return ret;
  }

   Future LocationInfo() async{
    Future<List<Konum>> konumFuture = databaseHelper.getKonum();
    konumFuture.then((konum){
        setState(() {
          this.konum = konum;           
        });
        loadMarketler(konum[0].lat,konum[0].lng,konum[0].radius);
      });         
  }

  Future loadMarketler(double lat,double lng,double distance) async {
    try {
      final String url = "https://zeybek.tk/find_json.php?lat=$lat&lng=$lng&radius=$distance";
      print(url);      
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      List parsedJson = json.decode(res.body);
      var categoryJson = parsedJson;
      marketler.clear();
      for (int i = 0; i < categoryJson.length; i++) {
        setState(() {
          marketler.add(new Yerler.fromJson(categoryJson[i]));  
        });        
      }
      setState(() {
        _progress=false;
      });
    } catch (e) {
      print(e);
    }
  }

  Future _launchURL(double lat,double lng) async {
    var url = "http://maps.apple.com/?daddr=$lat,$lng";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Marketlerim'),
        backgroundColor: Colors.red,
      ),
      body:  _progress==false ? marketler.length>0 ? ListView.builder(
        shrinkWrap: true,
        itemCount: marketler.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(marketler[index].name),
            subtitle: Text(marketler[index].adres),  
            leading: Icon(Icons.business),
            trailing: GestureDetector(
              child: Column(
                children: <Widget>[
                  Icon(Icons.directions_car),
                  Text(kmTomt(marketler[index].distance.toDouble())),                
                ],
              ), 
              onTap: (){                
                _launchURL(marketler[index].lat,marketler[index].lng);
              },
            ),                
            onTap: (){
              print("isme tıklandı");
            },
          );
        },
      ):Center(child: Text("Konumuzu yakın bir market bulunamadı"),) :Center(child:const CircularProgressIndicator(),),
    );
  }
}

class Yerler {
  String name;
  String adres;
  double lat;
  double lng;
  double distance;
  
  Yerler({
    this.name,
    this.adres,
    this.lat,
    this.lng,
    this.distance,
  });

    factory Yerler.fromJson(Map<String,dynamic> parsedJson) {
    return Yerler(
        name: parsedJson['name'] as String,      
        adres: parsedJson['address'] as String,
        lat: double.parse(parsedJson['lat']),
        lng: double.parse(parsedJson['lng']),
        distance: double.parse(parsedJson['distance'])
    );
  }
}
