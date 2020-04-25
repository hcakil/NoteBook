import 'dart:io';
import 'package:flutter_not_sepeti/models/kategori.dart';
import 'package:flutter_not_sepeti/models/notlar.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
class DatabaseHelper{
  static DatabaseHelper _databaseHelper;
  static Database _database;

  //factory denildiğinde burdaki  konstructora return ifadesi yazabiliyoruz
  factory DatabaseHelper(){
    if(_databaseHelper == null){
      _databaseHelper = DatabaseHelper._internal();
      return _databaseHelper;
    }
    else{
      return _databaseHelper;
    }
  }

  //Buda _internal şeklinde olan bir constructor
  DatabaseHelper._internal();

  //Eğer Database null ise onu oluşturmaya başla
  //Çözümü zaman alacak ve Database tipi dönecek
  Future<Database> _getDatabase () async {
    if(_database == null){
      _database = await _initilizaDatabase();
      return _database;
    }else{
      return _database;
    }
  }

  Future<Database> _initilizaDatabase() async {
   var lock = Lock();
    //burdan dönen _db gidip bizim _database e eşitleniyor
    Database _db;

      //uygulama açılırken içindeki bu yolda appDB adında bir database yoksa
    //gidip notlar.db Yi alıp getirecek
      if (_db == null) {
        await lock.synchronized(() async {
          if (_db == null) {
            print("Creating new copy from asset");
            var databasesPath = await getDatabasesPath();
            var path = join(databasesPath, "appDB.db");
            var file = new File(path);
            print("PATH   $databasesPath");
            // check if file exists
            if (!await file.exists()) {
              // Copy from asset
              ByteData data = await rootBundle.load(join("assets", "notlar.db"));
              List<int> bytes =
              data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
              await new File(path).writeAsBytes(bytes);
            }
            // open the database
            print("Opening existing database");
            _db = await openDatabase(path);
          }
        });


      return _db;
    }

/*    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "demo_asset_example.db");
    Database _db;

// Check if the database exists
    var exists = await databaseExists(path);

    if (!exists) {
      // Should happen only the first time you launch your application
      print("Creating new copy from asset");

      // Make sure the parent directory exists
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // Copy from asset
      ByteData data = await rootBundle.load(join("assets", "notlar.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

      // Write and flush the bytes written
      await File(path).writeAsBytes(bytes, flush: true);

    } else {
      print("Opening existing database");
    }
// open the database
    _db = await openDatabase(path, readOnly: false);
    return _db;*/
  }

  //KATEGORİ TABLOSU İLE YAPILACAK OLAN İŞLEMLER
  Future<List<Map<String,dynamic>>>kategorileriGetir() async {
    var db = await _getDatabase();
    //Bütün kategorileri içeren bir map döndürecek
    var sonuc = await db.query("kategori");
    return sonuc;
  }
  Future<List<Kategori>> kategoriListesiniGetir () async
  {
  var kategorileriIcerenMapListesi = await kategorileriGetir();
  var kategoriListesi = List<Kategori>();
  for(Map map in kategorileriIcerenMapListesi){
    kategoriListesi.add(Kategori.fromMap(map));
  }
  return kategoriListesi;
  }
  Future<int> kategoriEkle(Kategori kategori) async {
    //önce database e bak yoksa oluştur.
    var db = await _getDatabase();
    //Bütün kategorileri içeren bir map döndürecek
    var sonuc = await db.insert("kategori",kategori.toMap());
    return sonuc;
  }
  Future<int> kategoriGuncelle (Kategori kategori) async {
    //önce database e bak yoksa oluştur.
    var db = await _getDatabase();
    //Bütün kategorileri içeren bir map döndürecek
    var sonuc = await db.update("kategori",kategori.toMap(),where: "kategoriID = ?",whereArgs: [kategori.kategoriID]);
    return sonuc;
  }
  Future<int> kategoriSil (int kategoriID) async {
    //önce database e bak yoksa oluştur.
    var db = await _getDatabase();
    //Bütün kategorileri içeren bir map döndürecek
    var sonuc = await db.delete("kategori",where: "kategoriID = ?",whereArgs: [kategoriID]);
    return sonuc;
  }

  //NOTLAR TABLOSU İLE İLGİLİ YAPILAN İŞLEMLER

  Future<List<Map<String,dynamic>>> notlariGetir() async{
    var db= await _getDatabase();
    var sonuc = await db.rawQuery('select * from "not" inner join kategori on kategori.kategoriID = "not".kategoriID order by notID Desc;');
    return sonuc;
  }

  Future<List<Not>> notListesiniGetir() async{
    var notlarMapListesi =  await notlariGetir();
    var notListesi = List<Not>();
    for(Map map in notlarMapListesi){
      notListesi.add(Not.fromMap(map));
    }
    return notListesi;
  }


  Future<int> notEkle(Not not) async{
    var db= await _getDatabase();
    var sonuc = await db.insert("not", not.toMap());
    return sonuc;
  }

  Future<int> notGuncelle(Not not) async{
    var db= await _getDatabase();
    var sonuc = await db.update("not", not.toMap(), where: 'notID = ?', whereArgs: [not.notID]);
    return sonuc;
  }
  Future<int> notSil(int notID) async{
    var db= await _getDatabase();
    var sonuc = await db.delete("not", where: 'notID = ?', whereArgs: [notID]);
    return sonuc;
  }
  String dateFormat(DateTime tm){

    DateTime today = new DateTime.now();
    Duration oneDay = new Duration(days: 1);
    Duration twoDay = new Duration(days: 2);
    Duration oneWeek = new Duration(days: 7);
    String month;
    switch (tm.month) {
      case 1:
        month = "Ocak";
        break;
      case 2:
        month = "Şubat";
        break;
      case 3:
        month = "Mart";
        break;
      case 4:
        month = "Nisan";
        break;
      case 5:
        month = "Mayıs";
        break;
      case 6:
        month = "Haziran";
        break;
      case 7:
        month = "Temmuz";
        break;
      case 8:
        month = "Ağustos";
        break;
      case 9:
        month = "Eylül";
        break;
      case 10:
        month = "Ekim";
        break;
      case 11:
        month = "Kasım";
        break;
      case 12:
        month = "Aralık";
        break;
    }

    Duration difference = today.difference(tm);

    if (difference.compareTo(oneDay) < 1) {
      return "Bugün";
    } else if (difference.compareTo(twoDay) < 1) {
      return "Dün";
    } else if (difference.compareTo(oneWeek) < 1) {
      switch (tm.weekday) {
        case 1:
          return "Pazartesi";
        case 2:
          return "Salı";
        case 3:
          return "Çarşamba";
        case 4:
          return "Perşembe";
        case 5:
          return "Cuma";
        case 6:
          return "Cumartesi";
        case 7:
          return "Pazar";
      }
    } else if (tm.year == today.year) {
      return '${tm.day} $month';
    } else {
      return '${tm.day} $month ${tm.year}';
    }
    return "";


  }


}