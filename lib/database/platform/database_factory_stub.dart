import 'package:sqflite/sqflite.dart';

// ignore: unused_import
import 'database_factory_native.dart'
    if (dart.library.html) 'database_factory_web.dart';

DatabaseFactory? getStubDatabaseFactory() {
  return getDatabaseFactory();
}
