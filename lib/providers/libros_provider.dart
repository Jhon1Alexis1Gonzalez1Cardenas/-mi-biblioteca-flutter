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
}
