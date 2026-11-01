import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  DatabaseHelper({DatabaseFactory? fabrica, String? rutaBaseDeDatos})
      : _factory = fabrica,
        _ruta = rutaBaseDeDatos;

  static final DatabaseHelper instance = DatabaseHelper();

  static const String nombreArchivo = 'mi_biblioteca.db';
  static const int version = 1;

  /// Si es null se usa la fábrica de sqflite para Android.
  final DatabaseFactory? _factory;
  final String? _ruta;
  Database? _database;

  Future<Database> get database async {
    return _database ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final factory = _factory ?? databaseFactory;
    final ruta =
        _ruta ?? join(await factory.getDatabasesPath(), nombreArchivo);
    return factory.openDatabase(
      ruta,
      options: OpenDatabaseOptions(version: version, onCreate: _crear),
    );
  }

  Future<void> _crear(Database db, int version) async {
    await db.execute('''
      CREATE TABLE libros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL,
        autor TEXT NOT NULL,
        genero TEXT NOT NULL,
        anioPublicacion INTEGER NOT NULL,
        estadoLectura TEXT NOT NULL
      )
    ''');
  }

  Future<void> cerrar() async {
    await _database?.close();
    _database = null;
  }
}
