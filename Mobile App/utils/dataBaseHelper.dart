import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'package:safe/models/house_model.dart';
import 'package:safe/models/message_model.dart';

class DataBaseHelper {
  static DataBaseHelper _dataBaseHelper; //singleton
  static Database _dataBase;
  String housesTable = 'houses_table';
  String colId = 'id';
  String colName = 'name';
  String colPhone = 'phone';
  String colAdr = 'address';
  String messagesTable = 'messages_table';
  String colDatetime = 'datetime';
  String colContent = 'content';

  DataBaseHelper._();

  factory DataBaseHelper() {
    if (_dataBaseHelper == null)
      _dataBaseHelper = DataBaseHelper._(); //executed only the first time
    return _dataBaseHelper;
  }

  Future<Database> get database async {
    if (_dataBase == null) _dataBase = await initDatabase();

    return _dataBase;
  }

  Future<Database> initDatabase() async {
    Directory dir = await getApplicationDocumentsDirectory();
    String path = dir.path + 'houses.db';
    var housesDB = await openDatabase(
      path,
      onCreate: (db, version) {
         db.execute("CREATE TABLE $housesTable($colId INTEGER PRIMARY KEY, $colName TEXT, $colPhone TEXT, $colAdr TEXT)",);
        return db.execute("CREATE TABLE $messagesTable($colId INTEGER PRIMARY KEY, $colPhone TEXT, $colDatetime TEXT, $colContent TEXT)"
        );
      },
      version: 1,
    );
    return housesDB;
  }

  Future<List<Map<String, dynamic>>> getHouseMapList() async {
    final Database db = await this.database;
    var result = await db.query(housesTable, orderBy: '$colId ASC');
    return result;
  }

  Future<int> insertHouse(House house) async {
    final Database db = await this.database;
    var result = await db.insert(
        housesTable, house.toMap()); // YOU CAN ADD: ConflictAlgorithm.replace,
    return result;
  }

  Future<int> updateHouse(House house) async {
    final Database db = await this.database;
    var result = await db.update(housesTable, house.toMap(),
        where: "$colId = ?", whereArgs: [house.id]);
    return result;
  }

  Future<int> deleteHouse(House house) async {
    final Database db = await this.database;
    int result = await db
        .delete(housesTable, where: "$colId = ?", whereArgs: [house.id]);
    return result;
  }

  Future<int> getCount() async {
    final Database db = await this.database;
    var x = await db.rawQuery('SELECT COUNT (*) from $housesTable');
    return Sqflite.firstIntValue(x);
  }

  Future<List<House>> getHouseList() async {
    var mapList = await getHouseMapList();
    List<House> houses = List.empty(growable: true);
    for (int i = 0; i < mapList.length; i++)
      houses.add(House.fromMap(mapList[i]));
    return houses;
  }

  Future<List<Map<String, dynamic>>> getMsgMapList() async {
    final Database db = await this.database;
    final messagesList = await db.query(messagesTable);
    return messagesList;
  }

  Future<List<Message>> getMsgList(String phone) async {
    final List<Map<String, dynamic>> mapList = await getMsgMapList();
    List<Message> messageList = [];
    mapList.forEach((map) {
      if(phone==null || phone==map['phone'])
        messageList.add(Message.fromMap(map));
    });
    return messageList;
  }

  Future<int> insertMsg(Message msg) async {
    Database db = await this.database;
    final int result = await db.insert(messagesTable, msg.toMap());
    return result;
  }

  Future<int> updateMsg(Message msg) async {
    Database db = await this.database;
    final int result = await db.update(messagesTable, msg.toMap(),
        where: '$colId = ?', whereArgs: [msg.id]);
    return result;
  }

  Future<int> deleteMsg(Message msg) async {
    final Database db = await this.database;
    final int result = await db
        .delete(messagesTable, where: '$colId = ?', whereArgs: [msg.id]);
    return result;
  }
}
