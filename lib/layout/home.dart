import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './subpage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/utils/database_helper.dart';




class Home extends StatefulWidget  {

  Home({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  
  String _reader='';
  int _selectedBottomIndex = 1;

  List data;
  TextEditingController txtListeEkle = new TextEditingController();

  Future loadUrunler(String query) async { //for barcode_scan
    try {
      final String url = "http://zeybek.tk/api/detay.php?code="+query;
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

  Future<String> getSWData() async { // anasayfa ürünler load
    final String url = "http://zeybek.tk/api/liste.php?s=0";
    var res =  await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    setState(() {
      var resBody = json.decode(res.body);
      data = resBody;
    });

    return "Success!";
  }

  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Liste> liste;
  int count = 0; 
  int _selectedDrawerIndex = 0;

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
    int result = await databaseHelper.deleteListe(id);
    _showToastMsg(context, "Liste Silindi",Colors.orange);
    updateListe();
  }

  void _showSnackBar(BuildContext context,String message){
    final snackbar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackbar);
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

  void updateListe(){
     final Future<Database> dbFuture = databaseHelper.initializeDatabase();
     dbFuture.then((database){
       Future<List<Liste>> listeFuture = databaseHelper.getListe();
       listeFuture.then((liste){
         setState(() {
           this.liste = liste;
           this.count = liste.length;
         });
       });
     });
  }
  
  @override
  Widget build(BuildContext context) {

    if(liste==null){
      liste = List<Liste>();
      updateListe();
    }
    
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
              Navigator.pushNamed(context, "/search2"),
            }, 
          ),
          
          
         
        ],
      ),
      body: Center(
        child:  GridView.builder(
              primary: false,
              padding: const EdgeInsets.all(10),          
              itemCount: data == null ? 0 : data.length,                                                  
              gridDelegate:SliverGridDelegateWithFixedCrossAxisCount(
                 crossAxisCount: _selectedBottomIndex+1,
              ),
              itemBuilder: (BuildContext context, int index) {
              return  GestureDetector(
                  onTap: (){
                    Route route = MaterialPageRoute(builder: (context) => SubPage(
                      id: int.parse(data[index]["id"]),
                      stockCode: data[index]["stock_code"],
                      productName: data[index]["product_name"],
                      img: data[index]["img"],
                      remoteImg: data[index]["remote_img"],
                      remoteLink: data[index]["remote_link"], 
                      ));
                    Navigator.push(context, route);
                  },
                  child:  Container(
                     margin: EdgeInsets.all(10), 
                     color: Colors.white,
                    child:Stack( 
                    alignment: Alignment.center,                                                                              
                    children: [
                      FadeInImage.assetNetwork(                               
                        placeholder: "assets/images/loading.gif",
                        image: "http://zeybek.tk/api/images/"+data[index]["img"],                          
                        //image: data[index]["remote_img"], 
                      ),
                      Container(                                                      
                        alignment: Alignment.bottomCenter,                                    
                    child: Transform(                      
                      transform: Matrix4.skewY(0.0)..rotateZ(0),                      
                      child: Container( 
                        width: double.infinity,
                        padding: EdgeInsets.all(5),                        
                        color: Color(0xcdffffff),
                        child: Text(
                          data[index]["product_name"],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            ),
                            ),
                      ),
                    ),
                   
                  )
                    ],
                    ),),
                  );
              } 
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(            
        items:[
          BottomNavigationBarItem(
            icon: Icon(Icons.view_list),
            title: Text('Liste'),
          ),
           BottomNavigationBarItem( 
            icon: Icon(Icons.view_module),
            title: Text('Sıralı'),
          ),
           BottomNavigationBarItem(
            icon: Icon(Icons.view_comfy),
            title: Text('Grup'),
          ),
        ],        
        currentIndex: _selectedBottomIndex,
        onTap: _onItemTapped,
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
                              title: new Text("Liste Ekle"),
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
          
      setState(() => this._reader=reader);
    } on PlatformException catch(e) {
     if(e.code==BarcodeScanner.CameraAccessDenied) {
       //requestPermission();
       }
     else{setState(()=> _reader = "unknown exception $e");}
  }on FormatException{
      setState(() => _reader = 'null (User returned using the "back"-button before scanning anything. Result)');
    } catch (e) {
      setState(() => _reader = 'Unknown error: $e');
    }
 
  }

  /* barode scan finish */

 void _onItemTapped(int i){  //bottom menu
   
    setState(() {
      _selectedBottomIndex = i;
    });

    switch (i) {
      case 0:
        print("Liste");              
        break;
      case 1:
        print("Sıralı");
        break;
      case 2:
        print("Grup");
        
        break;
      default:
    }        
 }

 _onSelectItem(int index) {
     setState(() {
        _selectedDrawerIndex = index;  
      });
      Navigator.of(context).pop(); // close the drawer
  }

 @override
  void initState() {
    super.initState();
    this.getSWData();
  }
  

}

