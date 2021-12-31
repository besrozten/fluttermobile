import 'dart:async';

import 'package:movieapp/model/movie_local.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();

  static Database _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database;

    _database = await _initDB('movieapp.db');
    return _database;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute("""CREATE TABLE movies(
        id INTEGER PRIMARY KEY,
        title TEXT,
        poster_path TEXT,
        overview TEXT
        )
      """);
  }

  Future<int> insertMovie(MovieLocal movieLocal) async {
    final db = await instance.database;

    return await db.insert("movies", movieLocal.toMovieMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<List<MovieLocal>> getMovies() async {
    final db = await instance.database;
    var res = await db.rawQuery("select * from movies");

    return List.generate(res.length, (index) {
      return MovieLocal.fromJson(res[index]);
    });
  }

  Future<int> deleteMovie(int id) async {
    final db = await instance.database;
    var logins = db.delete("movies", where: "id = ?", whereArgs: [id]);
    return logins;
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
