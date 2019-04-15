import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';
import 'package:sqflite/sqflite.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import "package:google_maps_webservice/geocoding.dart" as ws;

class Maps extends StatefulWidget  {
  Maps({Key key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  TextEditingController txtController = TextEditingController();
  loc.Location location = new loc.Location(); 
  var searchRes = false;
  var yerler = List<Yerler>();
  double lat,lng;
  LatLng _lastMapPosition = LatLng(0, 0);
  CameraPosition _myLoc = CameraPosition(
    target: LatLng(38.467866199999996, 27.2184286),
    zoom: 13,
  );
  

  Future LocationInfo() async{
     
    loc.LocationData currentLocation;
    await location.changeSettings(
      accuracy: loc.LocationAccuracy.HIGH,
      interval: 1000,
    );  
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();      
       
      
       setState(() {
         _myLoc = CameraPosition(
            target: LatLng(currentLocation.latitude, currentLocation.longitude),
            zoom: 13,
          );

         lat = currentLocation.latitude;
         lng = currentLocation.longitude;
       });

       updateCam();
    
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //error = 'Permission denied';
      } 
      currentLocation = null;
    }
  }

  Future updateCam() async{
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_myLoc));
  }

  Future locationInfoDubug() async{
    var latitude = 38.467441;
    var longitude = 27.218683;    
    final CameraPosition _myLoc = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 13,
    );
      
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
                  onTap: ()=> locationInfoDubug(),
                ),
              ),
            ),
             searchList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          //getPlaces();
        },
        label: Text('Güncelle'),
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
              child: Icon(Icons.cancel),
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
              child: Icon(Icons.cancel),
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