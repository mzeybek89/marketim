import 'package:Marketim/layout/listeler/liste.dart';
import 'package:flutter/material.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Listelerim extends StatefulWidget  {
 Listelerim({Key key}) : super(key: key);
  @override
  _ListelerimPageState createState() => _ListelerimPageState(); 
}

class _ListelerimPageState extends State<Listelerim>  with SingleTickerProviderStateMixin {
  DatabaseHelper databaseHelper = DatabaseHelper();
  TextEditingController txtListeEkle = new TextEditingController();
  var count = 0;
  List<Liste> liste=[];

  void _deletelistItem(BuildContext context, int id) async{
    await databaseHelper.deleteListe(id);
    _showToastMsg(context, "Liste Silindi",Colors.orange);
    updateListe();
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
       Future<List<Liste>> listeFuture = databaseHelper.getListe();
       listeFuture.then((liste){
         setState(() {
           this.liste = liste;
           this.count = liste.length;
         });
       });
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

  @override
  void initState() {
    super.initState();
    updateListe();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Listelerim"),
      ),
      body: Column(        
        children: <Widget>[
          Expanded(
            child:  ListView.builder(
              itemCount: count+1,
              itemBuilder: (BuildContext context, int index){
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
                      title: Text(liste[index].title),
                      subtitle: Text(liste[index].count.toString()+" ürün var"),
                      onTap: (){
                        print(liste[index].id);
                        Route route = MaterialPageRoute(builder: (context) => Listem(
                          id: liste[index].id,   
                          title: liste[index].title,                    
                          ));
                          Navigator.push(context, route);
                      },
                      trailing: GestureDetector(
                          child: Icon(Icons.delete, color: Colors.grey,),
                          onTap: () {
                            showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text("Liste Silme Onay"),
                                      content: Text(liste[index].title +" Başlıklı Liste Silenecek Onaylıyor musunuz ?"),
                                      actions: <Widget>[
                                        new FlatButton(
                                          child: new Text("Vazgeç"),
                                          onPressed: () {              
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        new FlatButton(
                                        child: new Text("Sil"),
                                        onPressed: () {   
                                          _deletelistItem(context,liste[index].id); //listeyi sil
                                          databaseHelper.deleteUrunListeId(liste[index].id); // listeye bağlı olan ürünleri sil
                                          Navigator.of(context).pop();
                                        }                                                                            
                                      ),
                                      ],
                                    );
                                  },
                              );
                          },
                        ),
                    ),
                    Divider(
                      height: 2,
                    )
                  ],
                );
                
              },
            ),
          ),
        ],
      ),     
    );
  }
}

