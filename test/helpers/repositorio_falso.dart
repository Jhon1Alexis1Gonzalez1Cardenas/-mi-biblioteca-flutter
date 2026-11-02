import 'package:mi_biblioteca/data/libro_repository.dart';
import 'package:mi_biblioteca/models/libro.dart';

/// Repositorio en memoria para pruebas de provider y de widgets.
class RepositorioFalso extends LibroRepository {
  RepositorioFalso({List<Libro>? libros}) : libros = libros ?? [];

  final List<Libro> libros;
  int _siguienteId = 1;

  /// Simula fallos de SQLite para probar los estados de error.
  bool errorAlListar = false;
  bool errorAlInsertar = false;

  @override
  Future<List<Libro>> listar() async {
    if (errorAlListar) throw Exception('Fallo simulado al listar');
    return List.of(libros);
  }

  @override
  Future<Libro?> obtenerPorId(int id) async {
    for (final libro in libros) {
      if (libro.id == id) return libro;
    }
    return null;
  }

  @override
  Future<Libro> insertar(Libro libro) async {
    if (errorAlInsertar) throw Exception('Fallo simulado al insertar');
    final guardado = libro.copyWith(id: _siguienteId++);
    libros.insert(0, guardado);
    return guardado;
  }

  @override
  Future<bool> actualizar(Libro libro) async {
    final indice = libros.indexWhere((existente) => existente.id == libro.id);
    if (indice == -1) return false;
    libros[indice] = libro;
    return true;
  }

  @override
  Future<bool> eliminar(int id) async {
    final antes = libros.length;
    libros.removeWhere((libro) => libro.id == id);
    return libros.length < antes;
  }
}

Libro libroDePrueba({
  int id = 1,
  String titulo = 'La sombra del viento',
  String autor = 'Carlos Ruiz Zafón',
  String genero = 'Novela',
  int anioPublicacion = 2001,
  String estadoLectura = Libro.estadoLeyendo,
}) {
  return Libro(
    id: id,
    titulo: titulo,
    autor: autor,
    genero: genero,
    anioPublicacion: anioPublicacion,
    estadoLectura: estadoLectura,
  );
}
