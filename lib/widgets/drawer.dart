import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MyDrawer extends StatelessWidget{
  @override
  Widget build(BuildContext context) {   
    return Drawer(
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
                    Fluttertoast.showToast(
                        msg: "Şu anda liste ekleme  yapılamaz",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIos: 2,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0
                    )
                  },
                ),
              )
              
          ],
        )
      
          
      );
  }
  
}