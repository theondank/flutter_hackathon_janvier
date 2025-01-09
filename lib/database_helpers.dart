import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  Future<Database> _initializeDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'hemicycle.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            deputy_name TEXT NOT NULL,
            entry_time TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> insertEntry(String deputyName) async {
  final db = await database;

  // Obtenez l'heure actuelle au format français (dd/MM/yyyy HH:mm)
  final now = DateTime.now();
  final entryTime =
      '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
      '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

  await db.insert(
    'entries',
    {'deputy_name': deputyName, 'entry_time': entryTime},
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}


//   Future<void> insertEntry(String deputyName) async {
//   // Initialisez la base de données
//   final db = await initializeDatabase();

//   // Obtenez l'heure actuelle au format ISO 8601
//   final now = DateTime.now();
//   final entryTime = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

//   // Insérez les données dans la table
//   await db.insert(
//     'entries',
//     {
//       'deputy_name': deputyName,
//       'entry_time': entryTime,
//     },
//     conflictAlgorithm: ConflictAlgorithm.replace,
//   );
// }

  Future<List<Map<String, dynamic>>> getEntriesForDepute(String deputeName) async {
    final db = await database;
    return await db.query(
      'entries',
      where: 'deputy_name = ?',
      whereArgs: [deputeName],
    );
  }
}

// Future<List<Map<String, dynamic>>> getEntriesForDepute(String deputeId) async {
//   final db = await initializeDatabase();
//   final List<Map<String, dynamic>> entries = await db.query(
//     'entries',
//     where: 'deputy_name = ?',
//     whereArgs: [deputeId],
//   );
//   return entries;
// }



