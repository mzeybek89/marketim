import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import './subpage.dart';
import 'package:path_provider/path_provider.dart';
//import 'package:async_resource/file_resource.dart';




class Search extends StatefulWidget {
  Search({Key key}) : super(key: key);
  @override
  _SearchPageState createState() => new _SearchPageState();
}

class _SearchPageState extends State<Search> {
  TextEditingController editingController = TextEditingController();
  bool _progress = true;
  var duplicateItems = List<Urunler>();
 
  File jsonFile;
  Directory dir;
  String fileName = "urunler.json";
  bool fileExists = false;
  //Map<String, String> fileContent;
  List fileContent;

    Future loadUrunler() async {
    try {
  
      Directory directory = await getApplicationDocumentsDirectory();
      dir = directory;
      jsonFile = new File(dir.path + "/" + fileName);
      fileExists = jsonFile.existsSync();
      if (fileExists) {
        fileContent = json.decode( jsonFile.readAsStringSync());
      }
      var categoryJson = fileContent;
      for (int i = 0; i < categoryJson.length; i++) { 
        duplicateItems.add(new Urunler.fromJson(categoryJson[i]));
      }
      
     

      /*final String url = "http://zeybek.tk/api/liste.php?s=0&all=true";
      //String jsonString = await rootBundle.loadString('assets/players.json');
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      List parsedJson = json.decode(res.body);
      var categoryJson = parsedJson;
      for (int i = 0; i < categoryJson.length; i++) {
        duplicateItems.add(new Urunler.fromJson(categoryJson[i]));
      }*/
    } catch (e) {
      print(e);
    }
      items.addAll(duplicateItems);
      setState(() {
        _progress=false;
      });

  }


  var items = List<Urunler>();

  @override
  void initState() {
    loadUrunler();
    super.initState();
  }

  void filterSearchResults(String query) {
    List<Urunler> dummySearchList = List<Urunler>();
    dummySearchList.addAll(duplicateItems);
    if(query.isNotEmpty) {
      List<Urunler> dummyListData = List<Urunler>();

      dummySearchList.forEach((item) {
        if(item.productName.toLowerCase().contains(query.toLowerCase())) {
          dummyListData.add(item);
        }
      });
      setState(() {
        items.clear();
        items.addAll(dummyListData);
      });
      return;
    } else {
      setState(() {
        items.clear();
        items.addAll(duplicateItems);
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
            _progress == true?const CircularProgressIndicator():
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(items[index].productName),
                    subtitle: Text(items[index].stockCode),
                    onTap: (){
                       Route route = MaterialPageRoute(builder: (context) => SubPage(
                          id: items[index].id,
                          stockCode: items[index].stockCode,
                          productName: items[index].productName,
                          img: items[index].img,
                          remoteImg: items[index].remoteImg,
                          remoteLink: items[index].remoteLink, 
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