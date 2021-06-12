
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class Ids{
  Ids._();
  static const String AMBULANCE_ID = 'Ambulance';
  static const String FIRE_SERVICE_ID = 'FireService';
  static const String POLICE_STATION_ID = 'PoliceStation';
  static const String CALL_CENTER_ID = 'CallCenter';
}

class DBProvider {
  DBProvider._();
  static final DBProvider db = DBProvider._();

  static Database _database;

  Future<Database> get database async {
    if (_database != null)
      return _database;

    // if _database is null we instantiate it
    _database = await initDB();
    return _database;
  }

  initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = documentsDirectory.path+"/emecies.db";

    return await openDatabase(path, version: 1, onOpen: (db) {
    }, onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Ambulance ("
          "id INTEGER PRIMARY KEY,name TEXT,phone TEXT,address TEXT,lat TEXT,lon TEXT,icon BLOB,cover BLOB)");
      await db.execute("CREATE TABLE FireService ("
          "id INTEGER PRIMARY KEY,name TEXT,phone TEXT,address TEXT,lat TEXT,lon TEXT,icon BLOB,cover BLOB)");
      await db.execute("CREATE TABLE PoliceStation ("
          "id INTEGER PRIMARY KEY,name TEXT,phone TEXT,address TEXT,lat TEXT,lon TEXT,icon BLOB,cover BLOB)");
      await db.execute("CREATE TABLE CallCenter ("
          "id INTEGER PRIMARY KEY,name TEXT,phone TEXT,address TEXT,lat TEXT,lon TEXT,icon BLOB,cover BLOB)");
    });
  }

  clearTables() async{
    final db = await database;
    await db.delete("Ambulance");
    await db.delete("FireService");
    await db.delete("PoliceStation");
    await db.delete("CallCenter");
  }

  insertData({String table, Map<String, dynamic> data}) async{
    final db = await database;
    var res = await db.insert(table, data);
    return res;
  }
}