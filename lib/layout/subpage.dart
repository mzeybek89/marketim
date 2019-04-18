import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/utils/database_helper.dart';

class SubPage extends StatefulWidget  {

 
  SubPage({Key key,this.id,this.stockCode,this.productName,this.img,this.remoteImg,this.remoteLink}) : super(key: key);

  final int id;
  final String stockCode;
  final String productName;
  final String img;
  final String remoteImg;
  final String remoteLink;
  
  @override
  _MyHomePageState createState() => _MyHomePageState(); 
}

class _MyHomePageState extends State<SubPage>  with SingleTickerProviderStateMixin {
  //var f = new NumberFormat("####.00# ₺", "tr_TR");  
  var f = new NumberFormat.currency(locale: "tr_TR", name:"TL", symbol: "₺",decimalDigits: 2);
  TextEditingController yorumtxt = TextEditingController();
  String txt;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  var marketlerim = List<Marketlerim>();
  var details = List<Details>();


    @override
    void initState() {
      super.initState();
      LocationInfo();
    }

    @override
    void dispose() {
      super.dispose();
    }

    Future LocationInfo() async{
      Future<List<Konum>> konumFuture = databaseHelper.getKonum();
      konumFuture.then((konum){
          setState(() {
            this.konum = konum;
          });
          loadMarketler();
        });         
    }

   Future loadMarketler() async {
      try {
        var lat = konum[0].lat;
        var lng = konum[0].lng;
        var radius = konum[0].radius;
        var code = widget.stockCode;
        final String url = "http://zeybek.tk/api/detay.php?code=$code&lat=$lat&lng=$lng&radius=$radius";
        var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
        List parsedJson = json.decode(res.body);
        var categoryJson = parsedJson;
        marketlerim.clear();        
        for (int i = 0; i < categoryJson.length; i++) {
          setState(() {          
            marketlerim.add(new Marketlerim.fromJson(categoryJson[i]));  
          });        
        }        
        
      } catch (e) {
        print(e);
      }
    }
 

  @override
  Widget build(BuildContext context) {
/* Tabbarsız ilk düz sayfa versiyonu */
   return new Scaffold(
      appBar: AppBar(
        title: Text("Ürün Detay"),      
      ),
      body: Column( 
        children:<Widget>[          
        Expanded(
        child: ListView(               
          padding: EdgeInsets.all(10),          
          children: <Widget>[              
            Container(
              alignment: Alignment.topCenter,          
              padding: EdgeInsets.all(10),
              child: Text(
                widget.productName,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,              
                ),
              ),              
              color: Color(0xcd000000),
              height: 56,
            ),
            FadeInImage.assetNetwork(                               
              placeholder: "assets/images/loading.gif",
              image: "http://zeybek.tk/api/images/"+widget.img,                        
              //image: widget.remoteImg
            ),
            /*Text("Stock Code: "+widget.stockCode),      
            Container(
              alignment: Alignment.bottomRight,
              margin: EdgeInsets.fromLTRB(0, 10, 20, 0),
              child: Text(f.format(12),
              style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,              
                ),
              ),
            )*/
            /* Tüketici Memnunmu başla */
            Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text("Tüketici Memnun mu ?",
                textAlign: TextAlign.center,
                ),
            ),
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                children: <Widget>[
                  new LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 110,
                    lineHeight: 20.0,
                    animation: true,
                    animationDuration: 1500,
                    percent: 0.8,
                    center: Text("Çok Memnunum"),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.yellow.shade600,
                    leading: new Text("😍 " ,style: TextStyle(fontSize: 25),),
                    trailing: new Text(" 80%"),
                  ),
                  new LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 110,
                    lineHeight: 20.0,
                    animation: true,
                    animationDuration: 1500,
                    percent: 0.65,
                    center: Text("Memnunum"),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.green,
                    leading: new Text("😊 " ,style: TextStyle(fontSize: 25),),
                    trailing: new Text(" 65%"),
                  ),
                  new LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 110,
                    lineHeight: 20.0,
                    animation: true,
                    animationDuration: 1500,
                    percent: 0.75,
                    center: Text("İdare Eder"),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.blue,
                    leading: new Text("😐 " ,style: TextStyle(fontSize: 25),),
                    trailing: new Text(" 75%"),
                  ),
                  new LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 110,
                    lineHeight: 20.0,
                    animation: true,
                    animationDuration: 1500,
                    percent: 0.9,
                    center: Text("Memnun Değilim"),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.red,
                    leading: new Text("☹️ " ,style: TextStyle(fontSize: 25),),
                    trailing: new Text(" 90%"),
                  )
                ],
              ),
            ),
            /*Tüketici memnun mu bitir */
            
            /* Butonlar Başla*/
              RaisedButton(
                onPressed: () {},
                child: const Text('Alışveriş Listeme Ekle'),
              ),
              RaisedButton(
                onPressed: () {},
                child: const Text('Sık Alınanlara Ekle'),
              ),
              RaisedButton(                
                onPressed: () {},
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[                  
                  Text("Takip Et"),                                    
                  Text("(Fiyatı Düşünce Haber Ver)",style: TextStyle(fontSize: 12),),                  
                ],),
              ),
              /*Butonlar Bitir */      

              /*Marketler Fiyat Listesi Başla */  
              Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
              child: Text("Satış Yapan Marketler",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(10), 
                child: new ListView.builder(    
                  physics: const NeverScrollableScrollPhysics(),              
                  shrinkWrap: true,
                  itemCount: marketlerim.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      child: ListTile(                     
                        leading: Image.network("http://zeybek.tk/api/brand_image/"+marketlerim[index].brand.toLowerCase()+".png",width: 50,),                
                        title: Text(f.format(marketlerim[index].price)),
                        subtitle: Text(marketlerim[index].brand),                                              
                      ),
                      onTap: () {
                        showDialog(
                          context: context,                          
                          builder: (BuildContext context) {
                           return new AlertDialog(
                             contentPadding: EdgeInsets.all(0.0),
                              title: Center(child: Image.network("http://zeybek.tk/api/brand_image/"+marketlerim[index].brand.toLowerCase()+".png",width: 50,),),
                              content: new Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  ListView.builder(                                      
                                  shrinkWrap: true,
                                  itemCount: marketlerim[index].details.length,
                                  itemBuilder: (BuildContext context, int index2) {
                                      return ListTile(
                                          //leading: Icon(Icons.business),
                                          title: Text(marketlerim[index].details[index2].name),
                                          trailing: Text(f.format(marketlerim[index].details[index2].price)),
                                          subtitle: Text(marketlerim[index].details[index2].address),
                                      );
                                  }
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                new FlatButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  textColor: Theme.of(context).primaryColor,
                                  child: const Text('Kapat'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                     
                    );
                  },                  
                ),
              ),
              /*Marketler Fiyat Listesi Bitir */  

              /* Tüketici Yorumları Başla */
              Container(
              margin: EdgeInsets.fromLTRB(0, 10, 0, 15),
              child: Text("Kullanıcı Yorumları",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),
                ListTile(                     
                      //leading: Image.network("https://randomuser.me/api/portraits/women/28.jpg",width: 50,),                 
                      leading: ClipRRect(
                          borderRadius: new BorderRadius.circular(50.0),                          
                          child: Image.network(
                              "https://randomuser.me/api/portraits/women/28.jpg",                              
                              width: 50.0,
                          ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text("Özge",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),
                            Text("Harika Bir Ürün Ailecek Severek Tüketiyoruz",style: TextStyle(fontSize: 12),),
                        ],
                      ),                        
                      subtitle: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("12 Dk",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            Text("23 Beğeni",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            GestureDetector(
                              child: Text("Yanıtla",style: TextStyle(fontSize: 10),),
                              onTap: (){
                                print("Yanıtla Butonuna Basıldı");
                              },
                            )
                          ],)                          
                        ],
                      ),
                      trailing: Icon(Icons.favorite_border),                                              
                ),
                ListTile(                     
                      //leading: Image.network("https://randomuser.me/api/portraits/women/28.jpg",width: 50,),                 
                      leading: ClipRRect(
                          borderRadius: new BorderRadius.circular(50.0),                          
                          child: Image.network(
                              "https://randomuser.me/api/portraits/men/82.jpg",                              
                              width: 50.0,
                          ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text("Altan",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),
                            Text("Beklediğim gibi değildi tam bir hayal kırıklığı",style: TextStyle(fontSize: 12),),
                        ],
                      ),                        
                      subtitle: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("1 Saat",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            Text("0 Beğeni",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            GestureDetector(
                              child: Text("Yanıtla",style: TextStyle(fontSize: 10),),
                              onTap: (){
                                print("Yanıtla butonuna basıldı");
                              },
                            )
                          ],)                          
                        ],
                      ),
                      trailing: Icon(Icons.favorite_border),                                              
                ),
                ListTile(                     
                      //leading: Image.network("https://randomuser.me/api/portraits/women/28.jpg",width: 50,),                 
                      leading: ClipRRect(
                          borderRadius: new BorderRadius.circular(50.0),                          
                          child: Image.network(
                              "https://randomuser.me/api/portraits/women/50.jpg",                              
                              width: 50.0,
                          ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text("Merve",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),
                            Text("Bir sonraki indirimde alıcam",style: TextStyle(fontSize: 12),),
                        ],
                      ),                        
                      subtitle: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("2 Gün",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            Text("14 Beğeni",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            GestureDetector(
                              child: Text("Yanıtla",style: TextStyle(fontSize: 10),),
                              onTap: (){
                                print("Yanıtla Butonuna Basıldı");
                              },
                            )
                          ],)                          
                        ],
                      ),
                      trailing: Icon(Icons.favorite_border),                                              
                ),                
                ListTile(                     
                      //leading: Image.network("https://randomuser.me/api/portraits/women/28.jpg",width: 50,),                 
                      leading: ClipRRect(
                          borderRadius: new BorderRadius.circular(50.0),                          
                          child: Image.network(
                              "https://randomuser.me/api/portraits/women/84.jpg",                              
                              width: 50.0,
                          ),
                      ),
                      title: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                            Text("Buse",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13),),
                            Text("Bugün gidip almayı düşündüğüm ürün",style: TextStyle(fontSize: 12),),
                        ],
                      ),                        
                      subtitle: Column(
                         mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(children: <Widget>[
                            Text("1 Hafta",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            Text("9 Beğeni",style: TextStyle(fontSize: 10,),),
                            Padding(padding: EdgeInsets.fromLTRB(20,0,0,0)),
                            GestureDetector(
                              child: Text("Yanıtla",style: TextStyle(fontSize: 10),),
                              onTap: (){
                                print("Yanıtla Butonuna Basıldı");
                              },
                            )
                          ],)                          
                        ],
                      ),
                      trailing: Icon(Icons.favorite_border),                                              
                ),
              /* Tüketici Yorumları Bitir */
              /* Yorum Yap Başla */
              ListTile(
                leading: Icon(Icons.send),
                title:  TextField(
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Yorum Yazın'
                  ),         
                  textInputAction: TextInputAction.send,         
                  autocorrect: false,
                  autofocus: false,
                  controller: yorumtxt,
                  onSubmitted: (val){                                   
                    print(txt+" Yorumu gönderilecek");
                  },
                  onChanged: (val){                                     
                      txt = val;                    
                  },              
                ),
                trailing: GestureDetector(
                  child: Text("Gönder",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: (){
                        FocusScope.of(context).requestFocus(new FocusNode());
                        //var txt = yorumtxt.text.toString();
                        print(txt+" Yorumu Gönderilecek");
                    },
                ),
              )
               
              /*Yorum Yap Bitir */
            ],
          ),
        ),
        ],
      ),
    );
  }
}

class Details{
  String brand;
  String name;
  double price;
  String address;
  double lat;
  double lng;

  Details({
    this.brand,
    this.name,
    this.price,
    this.address,
    this.lat,
    this.lng
  });

  factory Details.fromJson(Map<String,dynamic> parsedJson){
    return Details(
      brand: parsedJson['brand'] as String,
      name: parsedJson['name'] as String,
      price: double.parse(parsedJson['price']),
      address: parsedJson['address'] as String,
      lat: double.parse(parsedJson['lat']),
      lng: double.parse(parsedJson['lng'])
    );
  }

}

class Marketlerim {
  String brand;
  String stockCode;
  String productName;
  double price;
  final List<Details> details;

  Marketlerim({
    this.brand,
    this.stockCode,
    this.productName,
    this.price,
    this.details
  });

  factory Marketlerim.fromJson(Map<String,dynamic> parsedJson) {

    var list = parsedJson['details'] as List;
    //print(list.runtimeType);
    List<Details> detailList = list.map((i) => Details.fromJson(i)).toList();

    return Marketlerim(
        brand: parsedJson['brand'] as String,
        stockCode: parsedJson['stock_code'] as String,
        productName: parsedJson['product_name'] as String,
        price: double.parse(parsedJson['price']),   
        details: detailList

    );  
  }
}
