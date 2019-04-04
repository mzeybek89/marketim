import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';



class Search extends StatefulWidget{
  @override
   _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<Search> {
  
  @override
  Widget build(BuildContext context) {
     return Scaffold(
        appBar: AppBar(
          title: Text('Ürün Arama'),
          /*actions: <Widget>[
            IconButton(
            icon: Icon(Icons.camera_alt),
            tooltip: 'Scan',
            onPressed:() {              
               FocusScope.of(context).requestFocus(FocusNode());
            }, 
            ),
          ],*/
        ),
        body: TypeAheadField(
        getImmediateSuggestions: true,
        //hideOnEmpty: false,
        hideSuggestionsOnKeyboardHide: false,      
        textFieldConfiguration: TextFieldConfiguration(                      
          autofocus: true,
          textInputAction: TextInputAction.done,
          style: TextStyle(
            fontSize: 20,
            decorationStyle: TextDecorationStyle.solid,
            decoration: TextDecoration.none,

          ), 
          decoration: InputDecoration(
            border: OutlineInputBorder()
          )
        ),
        suggestionsCallback: (pattern) async {
          final String url = "http://likyone.tk/api/liste.php?s=0";
          var res =  await http.get(Uri.parse(url), headers: {"Accept": "application/json"});
          return json.decode(res.body);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text(suggestion['product_name']),
            subtitle: Text(suggestion['stock_code']),
          );
        },
        onSuggestionSelected: (suggestion) {
          /*Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProductPage(product: suggestion)
          ));*/
          print(suggestion);          
        },
      ),
     );
  }

}

