import 'package:Marketim/models/konum.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:Marketim/utils/database_helper.dart';
//import 'package:Marketim/models/liste.dart';
import 'package:Marketim/models/urunler.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
//import 'dart:math';



class Listem extends StatefulWidget  {

 
  Listem({Key key,this.id,this.title}) : super(key: key);
  final int id;  
  final String title;
  @override
  _ListemPageState createState() => _ListemPageState(); 
}

class _ListemPageState extends State<Listem>  with SingleTickerProviderStateMixin {
  //var f = new NumberFormat("####.00# ₺", "tr_TR");
  var f = new NumberFormat.currency(locale: "tr_TR", name:"TL", symbol: "₺",decimalDigits: 2);
  TabController _tabController;
  ScrollController _scrollViewController;
  /*Color currentAppBarColor = Colors.black;
  final appBarColors = [
    Colors.black,
    Colors.red,
    Colors.orange,
    Colors.green,
    Colors.deepOrange,
    Colors.cyan,
    Colors.purple,
  ];*/

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  var count = 0;
  List<Urunler> urunler=[];
  String markersIds ="";
  String stockCodes ="";
  List<Markers> markers=[];
  bool _proggress = true;

 Future getUrunler()async{
   urunler.clear();
   var futureurunler = await databaseHelper.getUrunler(widget.id);
   setState(() {
     urunler = futureurunler;     
   });
   if(urunler.isEmpty){
     setState(() {
      markers.add(new Markers(id:-1,title: "Tümü"));
     _proggress = false;  
     });    
   }
   else{
      urunler.forEach((f){     
        markersIds += f.markerId.toString()+",";    
        stockCodes += f.stockCode+","; 
      });
      setState(() {
        markersIds = markersIds.substring(0,markersIds.length-1);
        stockCodes = stockCodes.substring(0,stockCodes.length-1);

      });
      
      getMarkers();
   }
  

   
 }

  Future locationInfo() async{
    Future<List<Konum>> konumFuture = databaseHelper.getKonum();
    konumFuture.then((konum){
        setState(() {
          this.konum = konum;
        });
      });         
  }

 Future getMarkers()async{
    var lat = konum[0].lat;
    var lng = konum[0].lng;
    var radius = konum[0].radius;    
   
    final String url = "http://zeybek.tk/api/listeDetay.php?lat=$lat&lng=$lng&radius=$radius&markersIds=$markersIds&stockCodes=$stockCodes";
    var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
    //print(url);
    List parsedJson = json.decode(res.body);
    var categoryJson = parsedJson;
    markers.clear();
    for (int i = 0; i < categoryJson.length; i++) {
      setState(() {          
        markers.add(new Markers.fromJson(categoryJson[i]));
        count = markers.length;        
      });        
    }
    
    setState(() {
      count = markers.length;        
      _tabController = TabController(vsync: this, length: count);
      _tabController.addListener(_handleTabSelection);
      _proggress=false;
    });
  
 }

  @override
  void initState() {
    super.initState();
    locationInfo();
    getUrunler();
    _tabController = TabController(vsync: this, length: 1);
    _tabController.addListener(_handleTabSelection);
    _scrollViewController =ScrollController();    
  }

 void _handleTabSelection() {
    setState(() {
      //currentAppBarColor = appBarColors[_tabController.index];
      print('Sayfa değişti');
    });
  }

 @override
 void dispose() {
   _tabController.dispose();
   _scrollViewController.dispose();
   super.dispose();
 }

  @override
  Widget build(BuildContext context) {
    
        return Scaffold(
          body:  _proggress==true ? Center(child:CircularProgressIndicator()):          
          NestedScrollView(
            controller: _scrollViewController,
            headerSliverBuilder: (BuildContext context, bool boxIsScrolled) {
              return <Widget>[               
                SliverAppBar(
                  title: Text(widget.title),
                  pinned: true,
                  //backgroundColor: currentAppBarColor,
                  floating: true,
                  forceElevated: boxIsScrolled,              
                  bottom: TabBar(                      
                    isScrollable: true,          
                    tabs: markers.map((Markers marker) {
                      return Tab(
                        text: marker.title,
                      );
                    }).toList(),
                    controller: _tabController,
                  ),
                ),
              ];
            },
            body: TabBarView(                             
              children: markers.asMap().map((i, element) => MapEntry(i, 
              element.id==-1 ? Center(  //Boş Liste Bölümü
                child:Text("Listenizde Ürün Bulunmuyor"),
              )
              :
              Center(
                child:Column(
                      children: <Widget>[
                        Expanded(
                          child: ListView.builder(
                            itemCount:element.details.length,
                            itemBuilder: (BuildContext context,int index){
                              return ListTile(
                                title: Text(element.details[index].productName,style: TextStyle(
                                  decoration: element.details[index].isChecked?TextDecoration.lineThrough:TextDecoration.none,
                                ),),
                                subtitle: Text(f.format(element.details[index].price)),
                                trailing: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: (){
                                     return showDialog(
                                      context: context,
                                      builder: (_) => new MyDialog(
                                      ));   
                                  },
                                ),
                                leading: new Checkbox(value: element.details[index].isChecked, onChanged: (bool newval){
                                  setState(() {
                                    element.details[index].isChecked=newval;
                                  });
                                }),
                              );
                            },
                          ),
                        ),
                        ListTile(
                          title: Text("Toplam Tutar : "+f.format(element.total)),
                        ),
                      ],
                    ),
              ),
              )).values.toList(),
              controller: _tabController,
            ),
        ),
          
        
    );
  }

  }

class Details{
  int id;
  String stockCode;
  String productName;
  double price;
  String img;
  String remoteImg;
  String remoteLink;
  bool isChecked;

  Details({
    this.id,
    this.stockCode,
    this.productName,
    this.price,
    this.img,
    this.remoteImg,
    this.remoteLink,
    this.isChecked,
  });

  factory Details.fromJson(Map<String,dynamic> parsedJson){
    return Details(
      id:int.parse(parsedJson['id']),
      stockCode: parsedJson['stock_code'] as String,
      productName: parsedJson['product_name'] as String,
      price: double.parse(parsedJson['price']),
      img: parsedJson['img'] as String,
      remoteImg: parsedJson['remote_img'] as String,
      remoteLink: parsedJson['remote_link'] as String,
      isChecked: false
    );
  }

}

class Markers{
  int id;
  String title;
  final List<Details> details;
  double total;

  Markers({this.id,this.title,this.details,this.total});
   
  factory Markers.fromJson(Map<String, dynamic> json){
   var list = json['details'] as List;   
   List<Details> detailList = list.map((i) => Details.fromJson(i)).toList();
    return Markers(
      id: int.parse(json['id']),
      title:json['brand'],
      details: detailList,
      total: double.parse(json['total'])
    );
  }
}




class MyDialog extends StatefulWidget {
  const MyDialog();

  @override
  State createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  DatabaseHelper databaseHelper = DatabaseHelper();




 
  listeEkleWidget(BuildContext context){
  return  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Liste Oluştur"),
          content: new Container(
          child: Text("deneme"),
              
        
          ),
  
        );
      },
  ); 
}



  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
   return new AlertDialog(
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
            Expanded(child:Text("İşlemler"),),
          ],),
          content: ListView(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            children: <Widget>[
              RaisedButton(
                child: Text("Market Değiştir"),
                onPressed: (){},
              ),
              RaisedButton(
                child: Text("Liste Değiştir"),
                onPressed: (){},
              ),
              RaisedButton(
                child: Text("Listeden Çıkar"),
                onPressed: (){},
              ),
            ],
          )
         
        );  
  }
}