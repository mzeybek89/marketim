import 'package:Marketim/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_scan/barcode_scan.dart';
//import 'package:simple_permissions/simple_permissions.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import './subpage.dart';




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
              Navigator.pushNamed(context, "/search"),
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
     drawer: MyDrawer(),
    
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
           Route route = MaterialPageRoute(builder: (context) => SubPage(
            id: 0,
            stockCode: reader,
            productName: reader,
            img: "nutella.png",
            remoteImg: "",
            remoteLink: "", 
            ));
          Navigator.push(context, route);
          
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
/*
// Method for scanning barcode....
  Future barcodeScanning() async {
//imageSelectorGallery();

    try {      
      String barcode = await FlutterBarcodeScanner.scanBarcode("#000000");
      setState(() => this.barcode = barcode);
    } on PlatformException catch (e) {
        setState(() => this.barcode = 'Unknown error: $e');
    } on FormatException {
      setState(() => this.barcode =
          'Nothing captured.');
    } catch (e) {
      setState(() => this.barcode = 'Unknown error: $e');
    }
  }*/

}