import 'db_helper.dart';

class ContactService {
  static Future<void> saveContacts(int userId, List<String> contacts) async {
    final db = await DBHelper.database;

    await db.delete(
      'emergency_contacts',
      where: 'user_id=?',
      whereArgs: [userId],
    );

    for (var phone in contacts) {
      await db.insert('emergency_contacts', {
        'user_id': userId,
        'phone': phone,
      });
    }
  }

  static Future<List<String>> getContacts(int userId) async {
    final db = await DBHelper.database;

    final res = await db.query(
      'emergency_contacts',
      where: 'user_id=?',
      whereArgs: [userId],
    );

    return res.map((e) => e['phone'] as String).toList();
  }

  static Future<void> addContact(int userId, String phone) async {
    final db = await DBHelper.database;
    await db.insert('emergency_contacts', {'user_id': userId, 'phone': phone});
  }

  static Future<void> deleteContact(int userId, String phone) async {
    final db = await DBHelper.database;
    await db.delete(
      'emergency_contacts',
      where: 'user_id=? AND phone=?',
      whereArgs: [userId, phone],
    );
  }
}
