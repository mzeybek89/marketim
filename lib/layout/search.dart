import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './subpage.dart';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/utils/database_helper.dart';
class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);
  

  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<Search> {
  TextEditingController editingController = TextEditingController();
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  var items = List<String>();
  var urunler = List<Urunler>();
  
  @override
  void initState() {
    locationInfo();
    super.initState();

  }

  Future locationInfo() async{
    Future<List<Konum>> konumFuture = databaseHelper.getKonum();
    konumFuture.then((konum){
        setState(() {
          this.konum = konum;
        });
      });         
  }

  Future loadUrunler(String query) async {
    try {
      var lat = konum[0].lat;
      var lng = konum[0].lng;
      var radius = konum[0].radius;
      final String url = "http://zeybek.tk/api/liste.php?q=$query&lat=$lat&lng=$lng&radius=$radius";
      //String jsonString = await rootBundle.loadString('assets/players.json');
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      List parsedJson = json.decode(res.body);
      var categoryJson = parsedJson;
      urunler.clear();
      //print(url);
      for (int i = 0; i < categoryJson.length; i++) {
        setState(() {          
          urunler.add(new Urunler.fromJson(categoryJson[i]));  
        });        
      }

    } catch (e) {
      print(e);
    }
  }



  Future filterSearchResults()async {  

    String query = editingController.text;
    //print(query);
    if(query!="" && query.length>2) {     
      setState(() {  
        loadUrunler(query);
      });
    } else {
      setState(() {
        items.clear();        
        urunler.clear();
      });
    }



  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Ürün Arama'),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                onChanged: (value) {
                  filterSearchResults();
                },
                autofocus: true,
                autocorrect: false,
                controller: editingController,
                decoration: InputDecoration(
                    labelText: "Search",
                    hintText: "Search",
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
              ),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: urunler.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(urunler[index].productName),
                    subtitle: Text(urunler[index].stockCode),
                    onTap: (){
                      Route route = MaterialPageRoute(builder: (context) => SubPage(
                          id: urunler[index].id,
                          stockCode: urunler[index].stockCode,
                          productName: urunler[index].productName,
                          img: urunler[index].img,
                          remoteImg: urunler[index].remoteImg,
                          remoteLink: urunler[index].remoteLink, 
                          ));
                          Navigator.push(context, route);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
   @override
  void dispose() {
    super.dispose();
  }
}


class Urunler {
  String stockCode;
  int id;
  String productName;
  String img;
  String remoteImg;
  String remoteLink;


  Urunler({
    this.stockCode,
    this.id,
    this.productName,
    this.img,
    this.remoteImg,
    this.remoteLink
  });

  factory Urunler.fromJson(Map<String,dynamic> parsedJson) {
    return Urunler(
        stockCode: parsedJson['stock_code'] as String,
        id: int.parse(parsedJson['id']),
        productName: parsedJson['product_name'] as String,
        img: parsedJson['img'] as String,
        remoteImg: parsedJson['remote_img'] as String,
        remoteLink: parsedJson['remote_link'] as String
    );  
  }
}


