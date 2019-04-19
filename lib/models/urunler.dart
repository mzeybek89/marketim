class Urunler{
  int _id;
  int _listeId;
  int _markerId;
  String _stockCode;
  
  Urunler(this._listeId,this._markerId,this._stockCode);
  Urunler.withId(this._id,this._listeId,this._markerId,this._stockCode);

  int get id => _id;
  int get listeId => _listeId;
  int get markerId => _markerId;
  String get stockCode => _stockCode;
  

  set listeId(int newlisteId)
  {
    if(newlisteId.toString().length>0)
    {
      this._listeId = newlisteId;
    }
  } 

  set markerId(int newmarkerId)
  {
    if(newmarkerId.toString().length>0)
    {
      this._markerId = newmarkerId;
    }
  } 

  set stockCode(String newstockCode)
  {
    if(newstockCode.toString().length>0)
    {
      this._stockCode = newstockCode;
    }
  } 

  Map<String,dynamic> toMap(){
    var map =Map<String,dynamic>();
    if(id!=null){
      map['id'] = _id;
    }
    map['listeId'] = _listeId;
    map['markerId'] = _markerId;
    map['stockCode'] = _stockCode;
    return map;
  }

  Urunler.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._listeId = map['listeId'];
    this._markerId = map['markerId'];
    this._stockCode = map['stockCode'];
  }

}