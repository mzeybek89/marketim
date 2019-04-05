import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './subpage.dart';
class Search3 extends StatefulWidget {
  Search3({Key key}) : super(key: key);
  

  @override
  _Search3PageState createState() => new _Search3PageState();
}

class _Search3PageState extends State<Search3> {
  TextEditingController editingController = TextEditingController();

  final duplicateItems = List<String>.generate(10000, (i) => "Item $i");
  var items = List<String>();
  var urunler = List<Urunler>();

  Future loadUrunler(String query) async {
    try {
      final String url = "http://likyone.tk/api/liste.php?q="+query;
      //String jsonString = await rootBundle.loadString('assets/players.json');
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      List parsedJson = json.decode(res.body);
      var categoryJson = parsedJson;
      urunler.clear();
      for (int i = 0; i < categoryJson.length; i++) {
        setState(() {
          urunler.add(new Urunler.fromJson(categoryJson[i]));  
        });
        
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    //items.addAll(duplicateItems);
     
    super.initState();
  }

  void filterSearchResults(String query) {
    //List<String> dummySearchList = List<String>();
    //dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {

      /*List<String> dummyListData = List<String>();
      dummySearchList.forEach((item) {
        if(item.contains(query)) {
          dummyListData.add(item);
        }
      });*/ 

     
    setState(() {
        //items.clear();
        //items.addAll(dummyListData);
        //urunler.clear();
        loadUrunler(query);
      });
      return;
    } else {
      setState(() {
        //items.clear();
        //items.addAll(duplicateItems);
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
                  filterSearchResults(value);
                },
                autofocus: true,
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