import 'package:path/path.dart';
import 'package:restaurant_app/database/restaurant.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  static late Database _database;

  DatabaseHelper._internal() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._internal();

  Future<Database> get database async {
    _database = await _initializeDb();
    return _database;
  }

  static const String _tableName = 'favorites';

  Future<Database> _initializeDb() async {
    var path = await getDatabasesPath();
    var db = openDatabase(
      join(path, 'favorites_db.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''CREATE TABLE $_tableName (
               id INTEGER PRIMARY KEY,
               restaurant_name TEXT,
               restaurant_id TEXT
             )''',
        );
      },
      version: 1,
    );

    return db;
  }

  Future<List<RestaurantSQLite>> getFavorite() async {
    final Database db = await database;
    List<Map<String,dynamic>> results = await db.rawQuery("SELECT restaurant_name,restaurant_id FROM $_tableName");
    List<RestaurantSQLite> restoran = results.map((it) => RestaurantSQLite.fromMap(it)).toList();
    return restoran;
  }

  Future<void> insertFavorite(String restaurantName,String restaurantId) async {
    final Database db = await database;
    await db.insert(_tableName, {'restaurant_name': restaurantName,'restaurant_id': restaurantId});
    print('$restaurantName masuk favorit');
  }


  Future<void> deleteFavorite(String restaurantId) async {
    final Database db = await database;
    await db.delete(
      _tableName,
      where: 'restaurant_id = ?',
      whereArgs: [restaurantId],
    );
    print("$restaurantId dihapus");
  }
}