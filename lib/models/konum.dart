class Konum{
  int _id;
  double _lat;
  double _lng;
  int _radius;
  
  Konum(this._lat,this._lng,this._radius);
  Konum.withId(this._id,this._lat,this._lng,this._radius);

  int get id => _id;
  double get lat => _lat;
  double get lng => _lng;
  int get radius => _radius;
  

  set lat(double newlat)
  {
    if(newlat.toString().length>0)
    {
      this._lat = newlat;
    }
  } 

  set lng(double newlng)
  {
    if(newlng.toString().length>0)
    {
      this._lng = newlng;
    }
  } 

  set radius(int newradius)
  {
    if(newradius.toString().length>0)
    {
      this._radius = newradius;
    }
  } 

  Map<String,dynamic> toMap(){
    var map =Map<String,dynamic>();
    if(id!=null){
      map['id'] = _id;
    }
    map['lat'] = _lat;
    map['lng'] = _lng;
    map['radius'] = _radius;
    return map;
  }

  Konum.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._lat = map['lat'];
    this._lng = map['lng'];
    this._radius = map['radius'];
  }

}