import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:qr_mobile_vision/qr_camera.dart';
import './subpage.dart';

class Barcode extends StatefulWidget {
  @override
  _BarcodeState createState() => new _BarcodeState();
}

class _BarcodeState extends State<Barcode> {

  String qr;
  bool camState = true;

  @override
  initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {  /*  
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Barkod Tarama'),
      ),
      body: new Center(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Expanded(
                child: camState
                    ? new Center(
                        child: new SizedBox(
                          width: double.infinity,
                          height: double.infinity,
                          child: new QrCamera(
                            onError: (context, error) => Text(
                                  error.toString(),
                                  style: TextStyle(color: Colors.red),
                                ),
                            qrCodeCallback: (code) {
                              setState(() {                                                              
                                qr = code;
                                camState = false;
                                         
                                    Route route = MaterialPageRoute(builder: (context) => SubPage(
                                                id: 0,
                                                stockCode: code,
                                                productName: code,
                                                img: "nutella.png",
                                                remoteImg: "",
                                                remoteLink: "", 
                                                ));
                                              Navigator.push(context, route);
                                  
                              });
                            },
                            //child: new Container(
                              //decoration: new BoxDecoration(
                                //color: Colors.transparent,
                                //border: Border.all(color: Colors.orange, width: 10.0, style: BorderStyle.solid),
                              //),
                            //),
                          ),
                        ),
                      )
                    : new Center(child: new Text("Kamera Kapalı"))),
            //new Text("QRCODE: $qr"),
          ],
        ),
      ),
      floatingActionButton: new FloatingActionButton(
          child: new Text(
            "Aç/Kapat",
            textAlign: TextAlign.center,
          ),
          onPressed: () {
            setState(() {
              camState = !camState;
            });
          }),
    ); */
  }
  
}