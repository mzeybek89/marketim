import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/utils/database_helper.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';



class Maps extends StatefulWidget  {
  Maps({Key key}) : super(key: key);

  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<Maps> {
  Completer<GoogleMapController> _controller = Completer();

  Future LocationInfo() async{
    
    LocationData currentLocation;

    var location = new Location();  
    location.changeSettings(
      accuracy: LocationAccuracy.HIGH,
    );  
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      currentLocation = await location.getLocation();
      final CameraPosition _myLoc = CameraPosition(
        target: LatLng(currentLocation.latitude, currentLocation.longitude),
        zoom: 14,
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

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static final CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
       appBar: AppBar(
        title: Text("Lokasyon Ayarı"),      
      ),
      body: GoogleMap(
        //cameraTargetBounds: CameraTargetBounds.unbounded,
        myLocationEnabled: false,        
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);          
        }
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: Text('To the lake!'),
        icon: Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));

  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    LocationInfo();
  }

}