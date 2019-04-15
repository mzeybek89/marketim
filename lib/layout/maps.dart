import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:Marketim/models/konum.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import "package:google_maps_webservice/geocoding.dart" as ws;
import 'package:sqflite/sqflite.dart';

class Maps extends StatefulWidget  {
  Maps({Key key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<Maps> {  
  DatabaseHelper databaseHelper = DatabaseHelper();
  List<Konum> konum;
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController txtController = TextEditingController();
  loc.Location location = new loc.Location(); 
  double _discreteValue = 51;
  var searchRes = false;
  var yerler = List<Yerler>();
  double lat,lng;
  LatLng _lastMapPosition = LatLng(0, 0);
  CameraPosition _myLoc = CameraPosition(
    target: LatLng(38.467866199999996, 27.2184286),
    zoom: 13,
  );
  

  Future LocationInfo() async{
    
    final Future<Database> dbFuture = databaseHelper.initializeDatabase();  
    dbFuture.then((database){     
      Future<List<Konum>> konumFuture = databaseHelper.getKonum();
      konumFuture.then((konum){
          setState(() {
            this.konum = konum; 
            print("Konum idsi ==> " + konum[0].id.toString());
          });
         getLocation();
        });        
    });
    
  }

  Future getLocation() async{
    if(konum==null){
      loc.LocationData currentLocation;
        await location.changeSettings(
          accuracy: loc.LocationAccuracy.HIGH,
          interval: 1000,
        );  
        // Platform messages may fail, so we use a try/catch PlatformException.
        try {
          currentLocation = await location.getLocation();      
          
          
          setState(() {           
            lat = currentLocation.latitude;
            lng = currentLocation.longitude;
          });
        
        } on PlatformException catch (e) {
          if (e.code == 'PERMISSION_DENIED') {
            //error = 'Permission denied';
          } 
          currentLocation = null;
        }
    }else{
      setState(() {
         lat = this.konum[0].lat;
         lng = this.konum[0].lng;
         _discreteValue = this.konum[0].radius;
       });
    }
     


      setState(() {
          _myLoc = CameraPosition(
            target: LatLng(lat, lng),
            zoom: 13,
          );
      });

      updateCam();
  }

  Future updateCam() async{
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myLoc));
  }


  Future getPlaces(String adres) async{    
    
    final geocoding = new ws.GoogleMapsGeocoding(apiKey: "AIzaSyBZJ7I2PmkUNq47W7bl6pZyfMU-ixfuEmU");
    ws.GeocodingResponse response = await geocoding.searchByAddress(adres,language: "tr",region: "tr");        
    if(response.results.length>0)
    {    
      for (int i = 0; i < response.results.length; i++) {
        
        setState(() {
          yerler.clear();
          searchRes = true;
          yerler.add(new Yerler(
            title: response.results[i].formattedAddress,
            lat: response.results[i].geometry.location.lat,
            lng: response.results[i].geometry.location.lng));  
        });        
      }
    }
    else
    {
      setState(() {
        searchRes = false;
      });
    }
 
  }


  Future camStop(ws.Location loc)async{    
    final geocoding = new ws.GoogleMapsGeocoding(apiKey: "AIzaSyBZJ7I2PmkUNq47W7bl6pZyfMU-ixfuEmU");  
    ws.GeocodingResponse res = await geocoding.searchByLocation(loc);
    String adres = res.results[3].formattedAddress.toString();
    setState(() {
      txtController.text=adres;
      txtController.selection = TextSelection.fromPosition(
        new TextPosition(offset:0),
      );
    });   
    FocusScope.of(context).requestFocus(new FocusNode());   
  }

void _onCameraMove(CameraPosition position) async{    
    setState(() {      
      _lastMapPosition = position.target;  
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: AppBar(
        title: Text("Konum Güncelle"),      
      ),
      body:
      Column(
        children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height-250,
              //padding: EdgeInsets.all(15),        
              child:Stack(        
                children:<Widget>[
                  GoogleMap(                        
                    tiltGesturesEnabled: true,
                    //cameraTargetBounds: CameraTargetBounds.unbounded,
                    myLocationEnabled: false,                 
                    mapType: MapType.normal,              
                    onCameraIdle: ()=>camStop(ws.Location(_lastMapPosition.latitude,_lastMapPosition.longitude)),
                    onCameraMove: _onCameraMove,
                    initialCameraPosition: _myLoc,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);          
                    },                      
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),              
                    child: Align(                
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: 30,
                          child: _txtField(),
                      ),
                    ),
                  ),           
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.center,                
                      child: Icon(Icons.location_on,color: Colors.red, size: 40,),                
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(0, 80, 20, 0),            
                    //padding: EdgeInsets.all(5),
                    child: Align(
                      alignment: Alignment.topRight,                
                      child: GestureDetector(
                        child: Container(                
                          width: 40,
                          height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white,     
                              borderRadius: new BorderRadius.circular(5.0),                    
                            ),
                            child: Icon(Icons.location_searching,color:Colors.grey),
                        ),
                        onTap: ()=> getLocation(),
                      ),
                    ),
                  ),
                  searchList(context),
                ],
              ),
            ),
            //Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 0),),
            ListTile(
              subtitle: Text("Mesafe "+'${_discreteValue.round()} km'),
              contentPadding: EdgeInsets.fromLTRB(15, 5, 15, 5),
              leading: Icon(Icons.home),
              trailing: Icon(Icons.local_shipping),
              title: Slider(            
                value: _discreteValue,
                min: 1,
                max: 100,                
                divisions: 8,
                label: '${_discreteValue.round()}',
                onChanged: (double value) {
                  setState(() {
                    _discreteValue = value;
                  });
                },               
              ),
            ),
            
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,    
      floatingActionButton: FloatingActionButton.extended(                
        onPressed: (){
          databaseHelper.updateKonum(Konum.withId(konum[0].id, _lastMapPosition.latitude, _lastMapPosition.longitude,_discreteValue));
        },
        label: Text('Konum Güncelle'),
        icon: Icon(Icons.save),
      ),
          
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocationInfo();
  }

  Widget _txtField(){
    return searchRes ? 
      TextField(                  
        decoration: new InputDecoration(
          hintText: "Adres Ara",
          fillColor: Colors.white,
          filled: true,                        
          //contentPadding: EdgeInsets.all(20),                        
          border: new OutlineInputBorder(                                                                            
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ), 
          ),
            prefixIcon: Icon(Icons.search),  
            suffixIcon: GestureDetector(
              child: Icon(Icons.cancel,color: Colors.grey,size: 25,),
              onTap: (){
                setState(() {
                  searchRes=false;
                  txtController.text="";
                });
              },
            )      
        ),
        style: TextStyle(fontSize: 12,),
        onChanged: (String txt) {
            getPlaces(txt);
        },
        controller: txtController,                
      )
      :
      TextField(                                  
        decoration: new InputDecoration(
          hintText: "Adres Ara",
          fillColor: Colors.white,
          filled: true,                         
          border: new OutlineInputBorder(                          
          borderRadius: new BorderRadius.circular(15.0),                                                                   
          ),          
           prefixIcon: Icon(Icons.search),  
            suffixIcon: GestureDetector(
              child: Icon(Icons.cancel,color: Colors.grey,size: 25,),
              onTap: (){
                setState(() {
                  searchRes=false;
                  txtController.text="";
                });
              },
            )           
        ),        
        style: TextStyle(fontSize: 12,),
        onChanged: (String txt) {
            getPlaces(txt);
        },              
        controller: txtController, 
      );

  }

  Widget searchList(BuildContext context){
    return searchRes ? 
      Padding(              
        padding: const EdgeInsets.fromLTRB(16, 69, 16, 15),                            
        child: Align(
          alignment: Alignment.topCenter,               
          child: Container(                                  
            //color: Colors.white,
            decoration: new BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(15),
                bottomRight: Radius.circular(15),
              ),               
            ),
            child:ListView.builder(
              padding: EdgeInsets.all(5),
               shrinkWrap: true,
                itemCount: yerler.length,
                itemBuilder: (context, index) {
                  return ListTile(                    
                    //leading: Icon(Icons.place),                    
                    title: Text(yerler[index].title,style: TextStyle(fontSize: 14)),
                    subtitle: Text(yerler[index].lat.toString()+", "+yerler[index].lng.toString(),style: TextStyle(fontSize: 10)),
                    onTap: (){  
                      setState(() {
                        _myLoc = CameraPosition(
                          target: LatLng(yerler[index].lat, yerler[index].lng),
                          zoom: 13,
                        );
                        _lastMapPosition = _myLoc.target;
                        txtController.text=yerler[index].title;
                        searchRes=false;                       
                      });                   
                      FocusScope.of(context).requestFocus(new FocusNode());          
                      updateCam();                                                         
                    },
                  );
                },
            )
          ),
        ),
      ) :
      Padding(padding: EdgeInsets.all(0));
  }

}



class Yerler {
  String title;
  double lat;
  double lng;
  
  Yerler({
    this.title,
    this.lat,
    this.lng
  });
}

