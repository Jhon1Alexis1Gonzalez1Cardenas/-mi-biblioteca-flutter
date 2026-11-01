import '../models/libro.dart';
import 'database_helper.dart';

/// Único lugar de la app que lee y escribe libros en SQLite.
class LibroRepository {
  Future<List<Libro>> listar() async {
    final db = await DatabaseHelper.instance.database;
    final filas = await db.query('libros', orderBy: 'id DESC');
    return filas.map(Libro.fromMap).toList();
  }

  Future<Libro> insertar(Libro libro) async {
    final db = await DatabaseHelper.instance.database;
    final id = await db.insert('libros', libro.toMap()..remove('id'));
    return libro.copyWith(id: id);
  }
}
