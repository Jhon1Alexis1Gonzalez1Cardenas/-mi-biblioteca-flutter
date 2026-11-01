import '../models/libro.dart';
import 'database_helper.dart';

/// Único lugar de la app que lee y escribe libros en SQLite.
class LibroRepository {
  LibroRepository({DatabaseHelper? databaseHelper})
      : _helper = databaseHelper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  Future<List<Libro>> listar() async {
    final db = await _helper.database;
    final filas = await db.query('libros', orderBy: 'id DESC');
    return filas.map(Libro.fromMap).toList();
  }

  Future<Libro?> obtenerPorId(int id) async {
    final db = await _helper.database;
    final filas = await db.query(
      'libros',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (filas.isEmpty) return null;
    return Libro.fromMap(filas.first);
  }

  Future<Libro> insertar(Libro libro) async {
    final db = await _helper.database;
    final id = await db.insert('libros', libro.toMap()..remove('id'));
    return libro.copyWith(id: id);
  }

  Future<bool> actualizar(Libro libro) async {
    final id = libro.id;
    if (id == null) {
      throw ArgumentError('El libro debe tener id para actualizarse');
    }
    final db = await _helper.database;
    final filas = await db.update(
      'libros',
      libro.toMap()..remove('id'),
      where: 'id = ?',
      whereArgs: [id],
    );
    return filas > 0;
  }

  Future<bool> eliminar(int id) async {
    final db = await _helper.database;
    final filas = await db.delete('libros', where: 'id = ?', whereArgs: [id]);
    return filas > 0;
  }
}
