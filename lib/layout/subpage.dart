import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/models/liste.dart';
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
  TextEditingController txtListeEkle = TextEditingController();
  String txt;
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  int _seciliListe=-1;
  bool alisverisListeEkleBtn = false;

  
  
  void _onValueChange(int value) {
    setState(() {
      _seciliListe = value;
    });
  }

  var marketlerim = List<Marketlerim>();
  var details = List<Details>();
    @override
    void initState() {
      super.initState();
      locationInfo();
    }

    @override
    void dispose() {
      super.dispose();
    }

    Future locationInfo() async{
      Future<List<Konum>> konumFuture = databaseHelper.getKonum();
      konumFuture.then((konum){
          setState(() {
            this.konum = konum;
          });
          loadMarketler();
          listemdemiKontrol();
        });         
    }

    Future listemdemiKontrol() async{
      var countFuture = await databaseHelper.getCountUrunlerWithWhere(widget.stockCode);
      if(countFuture==1){
        setState(() {
          alisverisListeEkleBtn=true;
        });
      }
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

    void _showToastMsg(BuildContext context,String message,Color color){
      Fluttertoast.showToast(
          msg: message,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIos: 1,
          backgroundColor: color,
          textColor: Colors.white,
          fontSize: 16,               
      );
    }

  alisverisListemeEkle(BuildContext context){
    return showDialog(
      context: context,
      child: new MyDialog(
        parent: this,
        onValueChange: _onValueChange,
        initialValue: _seciliListe,
        stockCode: widget.stockCode,
      ));    
  }

  Future alisverisListemdenCikar(BuildContext context)async{
    await databaseHelper.deleteUrun(widget.stockCode);
    setState(() {
      alisverisListeEkleBtn=false;
    });
    _showToastMsg(context, "Ürün Listeden Çıkarıldı",Colors.orange);
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
              
              alisverisListeEkleBtn ==false ?
              RaisedButton(
                onPressed: () { alisverisListemeEkle(context);},
                child: const Text('Alışveriş Listeme Ekle'),
              ):
              RaisedButton(
                onPressed: () { alisverisListemdenCikar(context);},
                child: const Text('Alışveriş Listemden Çıkar'),
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
  int id;
  String brand;
  String stockCode;
  String productName;
  double price;
  final List<Details> details;

  Marketlerim({
    this.id,
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
        id: int.parse(parsedJson['id']),
        brand: parsedJson['brand'] as String,
        stockCode: parsedJson['stock_code'] as String,
        productName: parsedJson['product_name'] as String,
        price: double.parse(parsedJson['price']),   
        details: detailList

    );  
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({this.parent,this.onValueChange, this.initialValue,this.stockCode});

  final _MyHomePageState parent;
  final int initialValue;
  final void Function(int) onValueChange;
  final String stockCode;
  


  @override
  State createState() => new MyDialogState();
}

class MyDialogState extends State<MyDialog> {
  DatabaseHelper databaseHelper = DatabaseHelper();
  int _seciliListe=-1;
  List<Liste> liste=[];
  TextEditingController txtListeEkle = TextEditingController();



  updataListe(){
     Future<List<Liste>> listeFuture = databaseHelper.getListe();
      listeFuture.then((gelenliste){
        setState(() {
          this.liste = gelenliste;
        });
      }); 
  }

  void _saveListe(BuildContext context,String title) async{
    var res = await databaseHelper.addListe(title);
    if(res!=0){
      widget.parent._showToastMsg(context, "Liste Eklendi",Colors.green);
    }
    else{
      widget.parent._showToastMsg(context, "Liste Eklemede Hata",Colors.red);
    }
  }


 
  listeEkleWidget(BuildContext context){
   txtListeEkle.text="";                  
  return  showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Liste Oluştur"),
          content: new Container(
            child: 
              TextField(
                autofocus: false,
                autocorrect: false,
                controller: txtListeEkle,
              ),
            
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text("Kaydet"),
              onPressed: () {
                if(txtListeEkle.text==""){
                  FocusScope.of(context).requestFocus(new FocusNode());
                  widget.parent._showToastMsg(context,"Lüften Yazı Alanını Boş Bırakmayın",Colors.red);
                }
                else{
                  /* Burada Liste Db Ye Kaydedilecek */                                    
                  //_saveListe(context,txtListeEkle.text);                                      
                  Navigator.of(context).pop();                 
                  _saveListe(context, txtListeEkle.text);  
                  updataListe();                
                }
              },
            ),
          ],
        );
      },
  ); 
}

selectMarker(BuildContext context, int listeId,String stockCode){
  print(listeId);
  print(stockCode);
  return showDialog(
      context: context,
      child:new MarketSec(
        parent: widget,
        stockCode: widget.stockCode,
        seciliListe: _seciliListe,
        ),
  );
}



  @override
  void initState() {
    super.initState();
    updataListe();
    _seciliListe = widget.initialValue;
  }

  Widget build(BuildContext context) {
   return new AlertDialog(
          title: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
            Expanded(child:Text("Liste Seç"),),
            IconButton(icon: Icon(Icons.add),onPressed: (){
                listeEkleWidget(context);
            },),
          ],),          
          content: liste.length==0 ? 
          new ListView(
            shrinkWrap: true,
            children:<Widget>[
              Container(
                child: Text("Üzgünüz Hiç Listeniz Yok Hemen Birtane Oluşturun"),
              )
            ]
          ): 
          new Row(   
            children:<Widget>[
              Flexible(child:ListView.builder(
                  itemCount: liste.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context,int i){
                    return RadioListTile(
                      title: Text(liste[i].title),
                      value: liste[i].id,
                      groupValue: _seciliListe,
                      onChanged: (int value) { 
                        setState(() {
                          _seciliListe = value;
                        });
                        widget.onValueChange(value); 
                      },
                    );
                  },
                ),
              ),
            ], 
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Vazgeç"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            liste.length==0 ?
            new FlatButton(
              child: new Text("Oluştur"),
              onPressed: () {
                listeEkleWidget(context);
              },
            )
            :
            new FlatButton(
              child: new Text("Seç"),
              onPressed: () {
                
                if(_seciliListe==-1){
                  widget.parent._showToastMsg(context,"Lüften Seçim Yapın",Colors.red);
                }
                else
                {
                  selectMarker(context,_seciliListe,widget.stockCode);              
                }
                
              },
            ),
          ],
        );  
  }
}



class MarketSec extends StatefulWidget {
  const MarketSec({this.parent,this.seciliListe,this.stockCode});

  final MyDialog parent;
  final int seciliListe;
  final String stockCode;
  
  @override
  State createState() => new MarketSecState();
}

class MarketSecState extends State<MarketSec> {
int markerSelectedIndex=-1;

Future _urunKaydet() async{
  int _listeId = widget.seciliListe;
  int _markerId = markerSelectedIndex;
  String  _stockCode = widget.stockCode;

  var res = await widget.parent.parent.databaseHelper.addUrun(_listeId, _markerId, _stockCode);
  return res;
}

  @override
  Widget build(BuildContext context) {
    return new AlertDialog(
        title: Text("Market Seç"),
        content: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ListView.builder(                                      
            shrinkWrap: true,
            itemCount: widget.parent.parent.marketlerim.length,
            itemBuilder: (BuildContext context, int index) {
                return RadioListTile(
                    //leading: Icon(Icons.business),
                    title: Text(widget.parent.parent.marketlerim[index].brand),
                    subtitle: Text(widget.parent.parent.f.format(widget.parent.parent.marketlerim[index].price)),
                    groupValue: markerSelectedIndex,
                    value: widget.parent.parent.marketlerim[index].id,
                    onChanged:(int val){ setState(() {
                      markerSelectedIndex=val;
                    }); },
                );
            }
            ),
          ],
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Text("Vazgeç"),
            onPressed: () {              
              Navigator.of(context).pop();
            },
          ),
          new FlatButton(
            child: new Text("Kaydet"),
            onPressed: () {
              print("db kayıt burada yapılacak");
                var res = _urunKaydet();
                if(res!=null){
                  widget.parent.parent.setState((){
                    widget.parent.parent.alisverisListeEkleBtn=true;
                  });
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  widget.parent.parent._showToastMsg(context,"Ürün Listenize Eklendi",Colors.green);                  
                }
                
            },
          ),
        ]

      );
  }
  
}