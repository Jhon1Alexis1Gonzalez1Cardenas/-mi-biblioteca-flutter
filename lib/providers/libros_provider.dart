import 'package:flutter/foundation.dart';

import '../data/libro_repository.dart';
import '../models/libro.dart';

class LibrosProvider extends ChangeNotifier {
  LibrosProvider({LibroRepository? repository})
      : _repository = repository ?? LibroRepository();

  final LibroRepository _repository;

  List<Libro> _libros = [];
  bool _cargando = false;
  String? _error;

  List<Libro> get libros => List.unmodifiable(_libros);
  bool get cargando => _cargando;
  String? get error => _error;
  bool get estaVacia => !_cargando && _error == null && _libros.isEmpty;

  Libro? buscarPorId(int id) {
    for (final libro in _libros) {
      if (libro.id == id) return libro;
    }
    return null;
  }

  Future<void> cargarLibros() async {
    _cargando = true;
    _error = null;
    notifyListeners();

    try {
      _libros = await _repository.listar();
    } catch (_) {
      _error = 'No se pudieron cargar tus libros. Intenta de nuevo.';
    } finally {
      _cargando = false;
      notifyListeners();
    }
  }

  Future<Libro?> obtenerPorId(int id) async {
    try {
      final libro = await _repository.obtenerPorId(id);
      if (libro == null) return null;
      _reemplazar(libro);
      notifyListeners();
      return libro;
    } catch (_) {
      return null;
    }
  }

  Future<bool> agregarLibro(Libro libro) async {
    try {
      final guardado = await _repository.insertar(libro);
      _libros = [guardado, ..._libros];
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> actualizarLibro(Libro libro) async {
    try {
      final actualizado = await _repository.actualizar(libro);
      if (!actualizado) return false;
      _reemplazar(libro);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarLibro(int id) async {
    try {
      final eliminado = await _repository.eliminar(id);
      if (!eliminado) return false;
      _libros = _libros.where((libro) => libro.id != id).toList();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  void _reemplazar(Libro libro) {
    _libros = [
      for (final existente in _libros)
        if (existente.id == libro.id) libro else existente,
    ];
  }
}
