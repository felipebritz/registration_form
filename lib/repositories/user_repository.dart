import 'package:registration_form/intra/db_sqlite.dart';
import 'package:registration_form/models/user.dart';

class UserRepository {
  final DBSQLite _db;
  UserRepository(this._db);

  Future<List<User>> get users async {
    var instance = await _db.instance;
    var usersDB = await instance.query('users');
    var users = usersDB.map((user) => User.fromMap(user)).toList();
    return users;
  }

  Future<int> saveUser(User user) async {
    var instance = await _db.instance;
    var idUser;
    if (user.id == null) {
      idUser = await instance.insert(
        'users',
        user.toMap(),
      );
    } else {
      idUser = await instance.update(
        'users',
        user.toMap(),
        where: 'id = ?',
        whereArgs: [
          user.id,
        ],
      );
    }
    return idUser;
  }

  Future<int> delete(User user) async {
    var instance = await _db.instance;
    return await instance.delete(
      'users',
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }
}
