import 'package:flutter/material.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import './urunler.dart';
import './subpage.dart';

class AutoComplete extends StatefulWidget {

  @override
  _AutoCompleteState createState() => new _AutoCompleteState();
}



class _AutoCompleteState extends State<AutoComplete> {

void _loadData() async {
  await UrunlerViewModel.loadUrunler();
}

@override
void initState() {
  // focus SimpleAutoCompleteTextField after it builds
    WidgetsBinding.instance.addPostFrameCallback((_) => FocusScope.of(context)
        .requestFocus(key.currentState.textField.focusNode));
  _loadData();
  super.initState();
}

  _AutoCompleteState();
  AutoCompleteTextField searchTextField;
  TextEditingController controller = new TextEditingController();
  GlobalKey<AutoCompleteTextFieldState<Urunler>> key = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Ürün Arama'),
        ),
        body: 
         searchTextField = AutoCompleteTextField<Urunler>(
                        style: new TextStyle(color: Colors.black, fontSize: 16.0),
                        decoration: new InputDecoration(
                        suffixIcon: Container(
                          width: 85.0,
                          height: 60.0,
                        ),
                        contentPadding: EdgeInsets.fromLTRB(10.0, 30.0, 10.0, 20.0),
                        filled: true,
                        hintText: 'Ürün Ara',
                        hintStyle: TextStyle(color: Colors.black)
                        ),                      
                        itemBuilder: (context, item) {
                          return   Container(                            
                            margin: EdgeInsets.all(10), 
                            color: Colors.white,
                            child:Stack( 
                            alignment: Alignment.bottomCenter,                                                                              
                            children: [
                              FadeInImage.assetNetwork(                               
                                placeholder: "assets/images/loading.gif",
                                image: "http://likyone.tk/api/images/"+item.img,  
                                height: 100,                  
                                //image: data[index]["remote_img"], 
                              ),
                              Container(                                                      
                                alignment: Alignment.bottomCenter,                                 
                                child: Transform(                      
                                  transform: Matrix4.skewY(0.0)..rotateZ(0), 
                                  alignment: Alignment.bottomCenter,                                                     
                                  child: Container( 
                                    width: double.infinity,
                                    padding: EdgeInsets.all(5),                        
                                    color: Color(0xcdffffff),
                                    child: Text(                                      
                                      item.productName,
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
                                ),
                          );
                            
                        },
                        itemFilter: (item, query) {
                          return item.productName
                          .toLowerCase()
                          .contains(query.toLowerCase());
                        },
                        itemSorter: (a, b) {
                          return a.productName.compareTo(b.productName);
                        },
                        itemSubmitted: (item) {
                          /*setState(() => 
                            searchTextField.textField.controller.text = item.productName
                          );*/
                          Route route = MaterialPageRoute(builder: (context) => SubPage(
                          id: item.id,
                          stockCode: item.stockCode,
                          productName: item.productName,
                          img: item.img,
                          remoteImg: item.remoteImg,
                          remoteLink: item.remoteLink, 
                          ));
                          Navigator.push(context, route);
                        },
                        key: key,
                        suggestions: UrunlerViewModel.urunler,
                      ),
        
    );
  }
}

