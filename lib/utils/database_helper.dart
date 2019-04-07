import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:Marketim/models/liste.dart';

class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  DatabaseHelper._createInstance();

  //Listeler Tablosu
  String listeTable = 'listeler';
  String colId = 'id';
  String colTitle = 'title';

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
    String path = directory.path + 'marketim.db';

    var marketimDatabase = openDatabase(path,version: 1, onCreate: _createDb);
    return marketimDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('CREATE TABLE $listeTable($colId INTEGER PRIMARY KEY AUTOINCREMENT,$colTitle TEXT)');
  }

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
  

}