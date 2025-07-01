import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('media.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 3, // Incremented to force migration check
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _onOpen, // Added to verify schema on open
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE favorites (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      path TEXT NOT NULL UNIQUE,
      title TEXT,
      artist TEXT,
      album TEXT,
      albumArt TEXT, -- Nullable TEXT for album art path
      duration INTEGER,
      added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add album and albumArt columns if missing
      await _addColumnIfNotExists(db, 'favorites', 'album', 'TEXT');
      await _addColumnIfNotExists(db, 'favorites', 'albumArt', 'TEXT');
    }
    if (oldVersion < 3) {
      // Add any future migrations here
      // Example: await db.execute('ALTER TABLE favorites ADD COLUMN new_column TEXT');
    }
  }

  Future<void> _onOpen(Database db) async {
    // Verify table schema on open
    final columns = await db.rawQuery('PRAGMA table_info(favorites)');
    final columnNames = columns.map((col) => col['name'] as String).toSet();
    final requiredColumns = {'id', 'path', 'title', 'artist', 'album', 'albumArt', 'duration', 'added_at'};

    if (!requiredColumns.every((col) => columnNames.contains(col))) {
      // Schema is invalid; drop and recreate table
      await db.execute('DROP TABLE IF EXISTS favorites');
      await _createDB(db, 3);
    }
  }

  Future<void> _addColumnIfNotExists(Database db, String table, String column, String type) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final columnNames = columns.map((col) => col['name'] as String).toList();
    if (!columnNames.contains(column)) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $type');
    }
  }

  Future<void> insertFavorite(Map<String, dynamic> favorite) async {
    final db = await database;
    try {
      await db.insert(
        'favorites',
        {
          'path': favorite['path'],
          'title': favorite['title'],
          'artist': favorite['artist'],
          'album': favorite['album'],
          'albumArt': favorite['albumArt'], // Handles null gracefully
          'duration': favorite['duration'] ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw DatabaseException('Failed to insert favorite: $e');
    }
  }

  Future<void> deleteFavorite(String path) async {
    final db = await database;
    try {
      await db.delete(
        'favorites',
        where: 'path = ?',
        whereArgs: [path],
      );
    } catch (e) {
      throw DatabaseException('Failed to delete favorite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getFavorites({
    String sortBy = 'added_at',
    bool ascending = false,
    String? searchQuery,
  }) async {
    final db = await database;
    try {
      String orderBy = '$sortBy ${ascending ? 'ASC' : 'DESC'}';
      String? whereClause;
      List<dynamic>? whereArgs;

      if (searchQuery != null && searchQuery.isNotEmpty) {
        whereClause = 'title LIKE ? OR artist LIKE ?';
        whereArgs = ['%$searchQuery%', '%$searchQuery%'];
      }

      return await db.query(
        'favorites',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: orderBy,
      );
    } catch (e) {
      throw DatabaseException('Failed to retrieve favorites: $e');
    }
  }

  Future<bool> isFavorite(String path) async {
    final db = await database;
    try {
      final result = await db.query(
        'favorites',
        where: 'path = ?',
        whereArgs: [path],
      );
      return result.isNotEmpty;
    } catch (e) {
      throw DatabaseException('Failed to check favorite status: $e');
    }
  }

  Future<void> deleteAllFavorites() async {
    final db = await database;
    try {
      await db.delete('favorites');
    } catch (e) {
      throw DatabaseException('Failed to delete all favorites: $e');
    }
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}

class DatabaseException implements Exception {
  final String message;
  DatabaseException(this.message);

  @override
  String toString() => 'DatabaseException: $message';
}