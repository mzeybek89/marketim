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
import "package:google_maps_webservice/geocoding.dart";







class Maps extends StatefulWidget  {
  Maps({Key key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();
  var location = new loc.Location(); 
  Future LocationInfo() async{
     
    loc.LocationData currentLocation;
    await location.changeSettings(
      accuracy: loc.LocationAccuracy.HIGH,
      interval: 1000,
    );  
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();      
      final CameraPosition _myLoc = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 11,
      );
      
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(_myLoc));

       
    
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        //error = 'Permission denied';
      } 
      currentLocation = null;
    }
  }

  Future locationInfoDubug() async{
    var latitude = 38.467441;
    var longitude = 27.218683;    
    final CameraPosition _myLoc = CameraPosition(
        target: LatLng(latitude, longitude),
        zoom: 11,
    );
      
    final GoogleMapController controller = await _controller.future;
    
    controller.animateCamera(CameraUpdate.newCameraPosition(_myLoc));
    
  } 

  Future getPlaces() async{    
    final geocoding = new GoogleMapsGeocoding(apiKey: "AIzaSyBZJ7I2PmkUNq47W7bl6pZyfMU-ixfuEmU");
    GeocodingResponse response = await geocoding.searchByAddress("edremit");
    print(response.results.length);  
    print(response.results[0].formattedAddress);
    print(response.results[0].geometry.location.lat);
    print(response.results[0].geometry.location.lng);    
    
    GeocodingResponse res = await geocoding.searchByLocation(response.results[0].geometry.location);
    print(res.results[2].formattedAddress);
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 11,
  );

  void camStop(){
    location.onLocationChanged().listen((LocationData currentLocation) {            
      //print(currentLocation.latitude);
      //print(currentLocation.longitude);
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
        padding: EdgeInsets.all(15),
        child:Stack(
          children:<Widget>[
            GoogleMap(
              tiltGesturesEnabled: true,
              //cameraTargetBounds: CameraTargetBounds.unbounded,
              myLocationEnabled: false,                 
              mapType: MapType.normal,
              onCameraIdle: ()=>camStop(),
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);          
              },        
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.topCenter,
                child: TextField(                  
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Yer Ara",
                    fillColor: Colors.white,
                  )                 
                ),
                /*child: FloatingActionButton(                  
                  onPressed: () => locationInfoDubug(),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.location_on, size: 30.0),
                ),*/
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Align(
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: ()=>locationInfoDubug(),
                  child: Icon(Icons.location_on,color: Colors.red, size: 40,),
                ),
                /*child: FloatingActionButton(                  
                  onPressed: () => locationInfoDubug(),
                  materialTapTargetSize: MaterialTapTargetSize.padded,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.location_on, size: 30.0),
                ),*/
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: (){
          getPlaces();
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

}