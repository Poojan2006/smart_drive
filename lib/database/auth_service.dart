import 'db_helper.dart';

class AuthService {

  static Future<int> register(String username, String password) async {
    final db = await DBHelper.database;
    return await db.insert('users', {
      'username': username,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>?> login(
      String username, String password) async {
    final db = await DBHelper.database;

    final res = await db.query(
      'users',
      where: 'username=? AND password=?',
      whereArgs: [username, password],
    );

    return res.isNotEmpty ? res.first : null;
  }
}
