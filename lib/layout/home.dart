import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './subpage.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/utils/database_helper.dart';
import './marketler/marketler.dart';




class Home extends StatefulWidget  {

  Home({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  
  String reader='';
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Liste> liste;
  List<Konum> konum;
  int count = 0; 
  int selectedDrawerIndex = 0;
  TextEditingController txtListeEkle = new TextEditingController();

  Future locationInfo() async{
    Future<List<Konum>> konumFuture = databaseHelper.getKonum();
    konumFuture.then((konum){
        setState(() {
          this.konum = konum;
        });
      });         
  }

  Future loadUrunler(String query) async { //for barcode_scan
    try {
      var lat = konum[0].lat;
      var lng = konum[0].lng;
      var radius = konum[0].radius;
      final String url = "http://zeybek.tk/api/barkod.php?code=$query&lat=$lat&lng=$lng&radius=$radius";
      //String jsonString = await rootBundle.loadString('assets/players.json');
      var res = await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
      Map<String, dynamic> gelen = json.decode(res.body);

      if(gelen==null){
          Route route = MaterialPageRoute(builder: (context) => SubPage(
            id: 0,
            stockCode: query,
            productName: 'Ürün Bulunamadı',
            img: 'notFound.png',
            remoteImg: '',
            remoteLink: '', 
            ));
            Navigator.push(context, route);
      }
      else
      {
        Route route = MaterialPageRoute(builder: (context) => SubPage(
            id: int.parse(gelen['id']),
            stockCode: query,
            productName: gelen['product_name'],
            img: gelen["img"],
            remoteImg: gelen['remote_img'],
            remoteLink: gelen['remote_link'], 
            ));
            Navigator.push(context, route);
      }

    } catch (e) {
      print(e);
    }
  }

  void _saveListe(BuildContext context,String title) async{
    var res = await databaseHelper.addListe(title);
    if(res!=0){
      _showToastMsg(context, "Liste Eklendi",Colors.green);
      updateListe();
    }
    else{
      _showToastMsg(context, "Liste Eklemede Hata",Colors.red);
    }
  }

  void _deletelistItem(BuildContext context, int id) async{
    await databaseHelper.deleteListe(id);
    _showToastMsg(context, "Liste Silindi",Colors.orange);
    updateListe();
  }

  /*void _showSnackBar(BuildContext context,String message){
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
  }*/

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

  void updateListe(){
   
       Future<List<Liste>> listeFuture = databaseHelper.getListe();
       listeFuture.then((liste){
         setState(() {
           this.liste = liste;
           this.count = liste.length;
         });
       });
   
  }
  
  @override
  Widget build(BuildContext context) {    
    if(liste==null){
      liste = List<Liste>();      
    }
    updateListe();
    
    return new Scaffold(
      appBar: AppBar(
        title: Text('Marketim'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.camera_alt),
            tooltip: 'Scan',
            onPressed:() => {              
              scan(),
            }, 
          ),
          IconButton(
            icon: Icon(Icons.search),
            tooltip: 'Search',
            onPressed:() => {
              Navigator.pushNamed(context, "/search"),
            }, 
          ),
        ],
      ),
      body:  GridView.count(
            primary: false,
            shrinkWrap: true,
            padding: const EdgeInsets.all(20),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            crossAxisCount: 2,
            children: <Widget>[
              GestureDetector(
                    child:  Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Container(                       
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.red.shade200,
                            borderRadius: BorderRadius.circular(10),
                          ),
                            child:Container(
                              width: 55,
                              height: 55,
                              alignment: Alignment.center,
                              /*decoration: BoxDecoration(              
                                image: DecorationImage(
                                  image: NetworkImage("https://cdn3.iconfinder.com/data/icons/text/100/list-512.png"), 
                                  alignment: Alignment.topCenter,                  
                                  fit: BoxFit.fitHeight,
                                  colorFilter: ColorFilter.srgbToLinearGamma(),
                                )                  
                              ),*/
                              child: Icon(Icons.list,size: 55,),
                            ),
                          ),
                        ),
                        Padding(padding: EdgeInsets.all(5),),
                        Text("Listelerim",style: TextStyle(fontWeight: FontWeight.bold),),
                      ],
                  ),
                onTap: (){
                  //Route route = MaterialPageRoute(builder: (context) => Marketler());
                  //Navigator.push(context, route);
                  print("Listeler Syafasına Yönlenicek");
                },
              ),             
             GestureDetector(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Container(                       
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                          child:Container(
                            width: 55,
                            height: 55,
                            alignment: Alignment.center,
                            child: Icon(Icons.business,size: 55,),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.all(5),),
                      Text("Marketler",style: TextStyle(fontWeight: FontWeight.bold),),
                    ],
                ),
                onTap: (){
                  Route route = MaterialPageRoute(builder: (context) => Marketler());
                  Navigator.push(context, route);
                },
             ),
              
            ],
      ),
     drawer: Drawer(
       child:Column(           
           mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: <Widget>[
            UserAccountsDrawerHeader(
                accountName: Text('Mehmet Zeybek'),                
                accountEmail: Text('mehmetzeybek@icloud.com'),
                currentAccountPicture:
                Image.asset("assets/images/profile.jpg"),
                decoration: BoxDecoration(color: Colors.blueAccent),  
                otherAccountsPictures: <Widget>[
                  GestureDetector(
                    child:Icon(Icons.location_on,color: Colors.white,),
                    onTap: (){
                      Navigator.pushNamed(context, "/maps");
                    },
                  ),
                ],            
             ),
             Expanded(
               child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: liste.length+1,          
                itemBuilder: (BuildContext context, int index) {
                 return index==liste.length ?  
                    Container(
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.fromLTRB(0, 20, 20, 20),
                  child: FloatingActionButton(
                    child:Icon(Icons.add),
                    onPressed: ()=> {
                      txtListeEkle.text="",                    
                      showDialog(
                          context: context,
                          builder: (BuildContext context2) {
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
                                    Navigator.of(context2).pop();
                                  },
                                ),
                                new FlatButton(
                                  child: new Text("Kaydet"),
                                  onPressed: () {
                                    if(txtListeEkle.text==""){
                                      FocusScope.of(context2).requestFocus(new FocusNode());
                                        return Fluttertoast.showToast(
                                          msg: "Lüften Yazı Alanını Boş Bırakmayın",
                                          toastLength: Toast.LENGTH_LONG,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIos: 2,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 16.0
                                      );
                                    }
                                    else{
                                      /* Burada Liste Db Ye Kaydedilecek */                                    
                                      _saveListe(context,txtListeEkle.text);                                      
                                      Navigator.of(context).pop();                                    
                                    }
                                  },
                                ),
                              ],
                            );
                          },
                        ), 
                    },
                  ),
                ) 
                : 
                   Column(
                    children: <Widget>[
                        ListTile(  
                        leading: Icon(Icons.list),                      
                        title: Text(liste[index].title),                        
                        trailing: GestureDetector(
                          child: Icon(Icons.delete, color: Colors.grey,),
                          onTap: () {
                            _deletelistItem(context,liste[index].id);
                          },
                        ),


                        onTap: () {
                          debugPrint("ListTile Tapped");
                          //navigateToDetail(this.noteList[position],'Edit Note');
                        },

                      ),
                      Divider(
                        height: 2.0,
                      ),                      
                    ],
                  );
                },
              ),
             )
              
            ],
       ),
      ),
    
    );
  }


  scan() async {
    try {
      String reader= await BarcodeScanner.scan();

          if (!mounted) {
            return;
          }
          
          loadUrunler(reader);        
          
      setState(() => this.reader=reader);
    } on PlatformException catch(e) {
     if(e.code==BarcodeScanner.CameraAccessDenied) {
       //requestPermission();
       }
     else{setState(()=> reader = "unknown exception $e");}
  }on FormatException{
      setState(() => reader = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => reader = 'Unknown error: $e');
    }
 
  }

  /* barode scan finish */


 @override
  void initState() {
    super.initState();
    //updateListe();
  }
  

}

