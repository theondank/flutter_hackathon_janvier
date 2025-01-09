import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Classe pour gérer la base de données SQLite
class DatabaseHelper {
  
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  
  Database? _database;

  // Retourne l'instance de la base de données, en l'initialisant si nécessaire.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initializeDatabase();
    return _database!;
  }

  // Initialise et configure la base de données SQLite.
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

  // Récupère le chemin complet du fichier de la base de données.
  Future<String> getDatabasePath() async {
    final databasesPath = await getDatabasesPath();
    return join(databasesPath, 'hemicycle.db');
  }

  // Fonction principale pour afficher le chemin de la base dans la console.
  void main() async {
    String dbPath = await getDatabasePath();
    print('Database path: $dbPath'); 
  }

  // Insère une nouvelle entrée dans la table `entries`.
  Future<void> insertEntry(String deputyName) async {
    final db = await database;

    // Génère l'heure actuelle au format français (dd/MM/yyyy HH:mm).
    final now = DateTime.now();
    final entryTime =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    // Insère les données dans la base.
    await db.insert(
      'entries',
      {'deputy_name': deputyName, 'entry_time': entryTime},
      conflictAlgorithm: ConflictAlgorithm.replace, 
    );
  }

  /// Récupère les entrées liées à un député spécifique.
  Future<List<Map<String, dynamic>>> getEntriesForDepute(String deputeName) async {
    final db = await database;

    // Requête pour filtrer les entrées par nom de député.
    return await db.query(
      'entries',
      where: 'deputy_name = ?',
      whereArgs: [deputeName],
    );
  }
}
