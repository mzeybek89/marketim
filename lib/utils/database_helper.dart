import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:Marketim/models/liste.dart';
import 'package:Marketim/models/konum.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  DatabaseHelper._createInstance();

  String colId = 'id';
  //Listeler Tablosu
  String listeTable = 'listeler';
  String colTitle = 'title';
  //Konum Tablosu
  String konumTable = 'konum';
  String colLat = "lat";
  String colLng = "lng";
  String colRadius = "radius";

  factory DatabaseHelper(){
    if(_databaseHelper==null)
    {
      _databaseHelper = DatabaseHelper._createInstance();
    }
    
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database==null){
      _database = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase()async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + '/marketim.db';

    var marketimDatabase = openDatabase(path,version: 1, onCreate: _createDb);
    return marketimDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $listeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT)');
    await db.execute('CREATE TABLE $konumTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colLat REAL,$colLng REAL,$colRadius REAL)');
  }


  /*void _upgradeDb(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS $listeTable");
    await db.execute("DROP TABLE IF EXISTS $konumTable");
      _createDb(db, newVersion);
  }*/
/*Liste Tablosu */
  Future<List<Map<String, dynamic>>>getListeMapList() async{
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * FROM $listeTable');
    var result = await db.query(listeTable);
    return result;
  }

  Future<List<Liste>> getListe() async{
    var listeMapList = await getListeMapList();
    int count = listeMapList.length;

    List<Liste> liste = List<Liste>();

    for (int i=0; i<count; i++){
      liste.add(Liste.fromMapObject(listeMapList[i]));
    }
    return liste;
  }

  Future<int> addListe(String title) async{
    Database db = await this.database;
    //var result = await db.insert('$listeTable', liste.toMap());
    var result = await db.rawInsert("insert into $listeTable ($colTitle) values('$title')");
    return result;
  }

  Future<int> updateListe(Liste liste) async{
    Database db = await this.database;
    var result = await db.update('$listeTable', liste.toMap(),where:'$colId = ?',whereArgs:[liste.id]);
    return result;
  }

  Future<int> deleteListe(int id) async{
    Database db = await this.database;
    var result = await db.rawDelete("delete from $listeTable where $colId=$id");
    return result;
  }

  Future<int> getCountListe() async{
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT(*) from $listeTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }
  

/*Konum Tablosu */

  Future<List<Map<String, dynamic>>>getKonumMapList() async{
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * FROM $konumTable');
    var result = await db.query(konumTable);
    return result;
  }

  Future<List<Konum>> getKonum() async{
    var konumMapList = await getKonumMapList();
    int count = konumMapList.length;

    List<Konum> konum = List<Konum>();

    for (int i=0; i<count; i++){
      konum.add(Konum.fromMapObject(konumMapList[i]));
    }
    return konum;
  }

  Future<int> addKonum(double lat,double lng,int radius) async{
    Database db = await this.database;
    //var result = await db.insert('$listeTable', liste.toMap());
    var result = await db.rawInsert("insert into $konumTable ($colLat,$colLng,$colRadius) values('$lat','$lng','$radius')");
    return result;
  }

  Future<int> updateKonum(Konum konum) async{
    Database db = await this.database;
    var result = await db.update('$konumTable', konum.toMap(),where:'$colId = ?',whereArgs:[konum.id]);
    return result;
  }

  Future<int> deleteKonum(int id) async{
    Database db = await this.database;
    var result = await db.rawDelete("delete from $konumTable where $colId=$id");
    return result;
  }

  Future<int> getCountKonum() async{
    Database db = await this.database;
    List<Map<String,dynamic>> x = await db.rawQuery('SELECT COUNT(*) from $konumTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }


}