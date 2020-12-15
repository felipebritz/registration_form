import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBSQLite {
  Database _instance;
  final versionDb = 1;

  static final DBSQLite _db = DBSQLite._();

  DBSQLite._();

  factory DBSQLite() {
    return _db;
  }

  Future<Database> get instance async {
    _instance ??= await _openDatabase();
    return _instance;
  }

  Future<Database> _openDatabase() async {
    var pathDB = await getDatabasesPath();
    var sqlite = openDatabase(
      join(pathDB, 'crud_users.db'),
      version: versionDb,
      onCreate: (db, version) {
        return db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            email TEXT,
            cpf TEXT,
            cep TEXT,
            street TEXT,
            number INTEGER,
            district TEXT,
            city TEXT,
            state TEXT,
            country TEXT
          );
        ''');
      }
    );
    return sqlite;
  }
}
