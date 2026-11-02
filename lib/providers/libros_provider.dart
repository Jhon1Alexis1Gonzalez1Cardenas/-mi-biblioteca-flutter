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
  String _busqueda = '';
  String? _filtroEstado;

  List<Libro> get libros => List.unmodifiable(_libros);
  bool get cargando => _cargando;
  String? get error => _error;

  /// Texto actual del buscador.
  String get busqueda => _busqueda;

  /// Estado seleccionado en los chips; null equivale a "Todos".
  String? get filtroEstado => _filtroEstado;

  bool get hayFiltros => _busqueda.trim().isNotEmpty || _filtroEstado != null;

  /// Libros que cumplen la búsqueda por título/autor y el filtro de estado.
  List<Libro> get librosFiltrados {
    final termino = normalizarTexto(_busqueda.trim());

    return _libros.where((libro) {
      if (_filtroEstado != null && libro.estadoLectura != _filtroEstado) {
        return false;
      }
      if (termino.isEmpty) return true;

      return normalizarTexto(libro.titulo).contains(termino) ||
          normalizarTexto(libro.autor).contains(termino);
    }).toList();
  }

  bool get estaVacia => !_cargando && _error == null && _libros.isEmpty;

  bool get sinResultados =>
      !_cargando &&
      _error == null &&
      _libros.isNotEmpty &&
      librosFiltrados.isEmpty;

  void buscar(String texto) {
    if (_busqueda == texto) return;
    _busqueda = texto;
    notifyListeners();
  }

  void filtrarPorEstado(String? estado) {
    if (_filtroEstado == estado) return;
    _filtroEstado = estado;
    notifyListeners();
  }

  void limpiarFiltros() {
    if (!hayFiltros) return;
    _busqueda = '';
    _filtroEstado = null;
    notifyListeners();
  }

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
      _libros = [];
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

const String _conTildes = 'áàäâãéèëêíìïîóòöôõúùüûñç';
const String _sinTildes = 'aaaaaeeeeiiiiooooouuuunc';

/// Pasa el texto a minúsculas y quita tildes para comparar búsquedas.
String normalizarTexto(String texto) {
  var resultado = texto.toLowerCase();
  for (var i = 0; i < _conTildes.length; i++) {
    resultado = resultado.replaceAll(_conTildes[i], _sinTildes[i]);
  }
  return resultado;
}
