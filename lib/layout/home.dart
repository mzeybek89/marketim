import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './subpage.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';




class Home extends StatefulWidget  {

  Home({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Home> {
  String _reader='';
  int _selectedBottomIndex = 1;
  final String url = "http://likyone.tk/api/liste.php?s=0";
  List data;
  TextEditingController txtListeEkle = new TextEditingController();

  Future loadUrunler(String query) async {
    try {
      final String url = "http://likyone.tk/api/detay.php?code="+query;
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


  Future<String> getSWData() async {
    var res =  await http.get(Uri.parse(url), headers: {"Accept": "application/json"});

    setState(() {
      var resBody = json.decode(res.body);
      data = resBody;
    });

    return "Success!";
  }

  @override
  Widget build(BuildContext context) {


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
                        image: "http://likyone.tk/api/images/"+data[index]["img"],                          
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
        //elevation: 20.0,        
        child:ListView( 
          padding: EdgeInsets.zero,
          children: <Widget>[
             UserAccountsDrawerHeader(
                accountName: Text('Mehmet Zeybek'),                
                accountEmail: Text('mehmetzeybek@icloud.com'),
                currentAccountPicture:
                Image.network('https://bit.ly/2U0JsMd'),
                decoration: BoxDecoration(color: Colors.blueAccent),
              ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Temizlik Listesi'),
                onTap: () {                  
                  Navigator.pop(context); // close the drawer
                },                
              ), 
                Divider(
                  height: 2.0,
                ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Yiyecek Listesi'),
                onTap: () {                  
                  Navigator.pop(context); // close the drawer
                },                
              ),
              Divider(
                  height: 2.0,
                ),
              ListTile(
                leading: Icon(Icons.list),
                title: Text('Aburcubur Listesi'),
                onTap: () {                  
                  Navigator.pop(context); // close the drawer
                },                
              ),
              
              Container(
                alignment: Alignment.bottomRight,
                margin: EdgeInsets.fromLTRB(0, 20, 20, 0),
                child: FloatingActionButton(
                  child:Icon(Icons.add),
                  onPressed: ()=> {
                    txtListeEkle.text="",                    
                     showDialog(
                        context: context,
                        builder: (BuildContext context) {
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
                                  Navigator.of(context).pop();
                                },
                              ),
                              new FlatButton(
                                child: new Text("Kaydet"),
                                onPressed: () {
                                  if(txtListeEkle.text==""){
                                    FocusScope.of(context).requestFocus(new FocusNode());
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
                                    Navigator.of(context).pop();
                                     Fluttertoast.showToast(
                                        msg: "Liste Kaydedilme İşlemi Henüz Yapılamıyor",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIos: 2,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 16.0
                                    );
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
              
          ],
        )
      ),
    
    );
  }


/*barcode scan start*//*
 requestPermission() async {
    PermissionStatus result = await SimplePermissions.requestPermission(permission);
    setState(()=> new SnackBar
    (backgroundColor: Colors.red,content: new Text(" $result"),),
    
    );
  }*/
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

 void _onItemTapped(int i){
   
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

 @override
  void initState() {
    super.initState();
    this.getSWData();
  }
  

}
