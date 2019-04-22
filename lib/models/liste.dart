class Liste{
  int _id;
  String _title;
  int _count;
  Liste(this._title);
  Liste.withId(this._id,this._title);

  int get id => _id;
  String get title => _title;
  int get count => _count;
  
  set title(String newTitle)
  {
    if(newTitle.length>0)
    {
      this._title = newTitle;
    }
  } 

  set count(int newCount)
  {    
    this._count = newCount;      
  } 

  Map<String,dynamic> toMap(){
    var map =Map<String,dynamic>();
    if(id!=null){
      map['id'] = _id;
    }
    if(count!=null){
      map['count'] = _count;
    }
    map['title'] = _title;
    return map;
  }

  Liste.fromMapObject(Map<String, dynamic> map){
    this._id = map['id'];
    this._title = map['title'];
    if( map['count']!=null){
      this._count = map['count'];
    }
  }

}