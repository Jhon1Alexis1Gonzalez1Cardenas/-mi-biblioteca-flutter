import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mi_biblioteca/data/libro_repository.dart';
import 'package:mi_biblioteca/models/libro.dart';
import 'package:mi_biblioteca/providers/libros_provider.dart';
import 'package:mi_biblioteca/screens/lista_libros_screen.dart';
import 'package:mi_biblioteca/theme/app_theme.dart';

class _RepositorioFalso extends LibroRepository {
  _RepositorioFalso({List<Libro>? libros}) : _libros = libros ?? [];

  final List<Libro> _libros;
  int _siguienteId = 1;

  @override
  Future<List<Libro>> listar() async => List.of(_libros);

  @override
  Future<Libro?> obtenerPorId(int id) async {
    for (final libro in _libros) {
      if (libro.id == id) return libro;
    }
    return null;
  }

  @override
  Future<Libro> insertar(Libro libro) async {
    final guardado = libro.copyWith(id: _siguienteId++);
    _libros.insert(0, guardado);
    return guardado;
  }

  @override
  Future<bool> actualizar(Libro libro) async {
    final indice = _libros.indexWhere((existente) => existente.id == libro.id);
    if (indice == -1) return false;
    _libros[indice] = libro;
    return true;
  }

  @override
  Future<bool> eliminar(int id) async {
    final antes = _libros.length;
    _libros.removeWhere((libro) => libro.id == id);
    return _libros.length < antes;
  }
}

Widget _crearApp(LibroRepository repositorio) {
  return ChangeNotifierProvider(
    create: (_) => LibrosProvider(repository: repositorio),
    child: MaterialApp(
      theme: AppTheme.lightTheme,
      home: const ListaLibrosScreen(),
    ),
  );
}

/// Usa una pantalla alta para que todo el contenido quede visible sin scroll.
void _pantallaAlta(WidgetTester tester) {
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('Muestra el estado vacío cuando no hay libros', (tester) async {
    await tester.pumpWidget(_crearApp(_RepositorioFalso()));
    await tester.pumpAndSettle();

    expect(find.text('Tu biblioteca está vacía'), findsOneWidget);
    expect(find.text('Agregar libro'), findsOneWidget);
  });

  testWidgets('Lista los libros guardados', (tester) async {
    final repositorio = _RepositorioFalso(
      libros: [
        Libro(
          id: 1,
          titulo: 'La sombra del viento',
          autor: 'Carlos Ruiz Zafón',
          genero: 'Novela',
          anioPublicacion: 2001,
          estadoLectura: Libro.estadoLeyendo,
        ),
      ],
    );

    await tester.pumpWidget(_crearApp(repositorio));
    await tester.pumpAndSettle();

    // El título aparece en la portada y en el encabezado de la tarjeta.
    expect(find.text('La sombra del viento'), findsWidgets);
    expect(find.text('Carlos Ruiz Zafón'), findsOneWidget);
    expect(find.text('Leyendo'), findsOneWidget);
  });

  testWidgets('Valida título y autor obligatorios al guardar', (tester) async {
    await tester.pumpWidget(_crearApp(_RepositorioFalso()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar libro'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar libro'));
    await tester.pumpAndSettle();

    expect(find.text('El título es obligatorio'), findsOneWidget);
    expect(find.text('El autor es obligatorio'), findsOneWidget);
  });

  testWidgets('Guarda un libro nuevo y lo muestra en la lista', (tester) async {
    final repositorio = _RepositorioFalso();
    await tester.pumpWidget(_crearApp(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar libro'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Escribe el título'),
      'Nada',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre del autor o autora'),
      'Carmen Laforet',
    );

    await tester.tap(find.text('Guardar libro'));
    await tester.pumpAndSettle();

    expect(repositorio._libros, hasLength(1));
    expect(find.text('Nada'), findsWidgets);
    expect(find.text('Carmen Laforet'), findsOneWidget);
  });

  testWidgets('El detalle muestra los datos del libro', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(_RepositorioFalso(libros: [_libroDemo()])));
    await tester.pumpAndSettle();

    await tester.tap(find.text('La sombra del viento').first);
    await tester.pumpAndSettle();

    expect(find.text('Detalle del libro'), findsOneWidget);
    expect(find.text('La sombra del viento'), findsWidgets);
    expect(find.text('Carlos Ruiz Zafón'), findsOneWidget);
    expect(find.text('Progreso de lectura'), findsOneWidget);
    expect(find.text('Novela'), findsOneWidget);
    expect(find.text('2001'), findsOneWidget);
    expect(find.text('Editar libro'), findsOneWidget);
    expect(find.text('Eliminar libro'), findsOneWidget);
  });

  testWidgets('Editar cambia el estado y vuelve al detalle', (tester) async {
    _pantallaAlta(tester);
    final repositorio = _RepositorioFalso(libros: [_libroDemo()]);
    await tester.pumpWidget(_crearApp(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.text('La sombra del viento').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Editar libro'));
    await tester.pumpAndSettle();

    expect(find.text('Editar libro'), findsOneWidget);
    expect(find.text('Guardar cambios'), findsOneWidget);
    expect(find.text('Descartar cambios'), findsOneWidget);

    await tester.tap(find.text('Terminado'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar cambios'));
    await tester.pumpAndSettle();

    expect(repositorio._libros.first.estadoLectura, Libro.estadoTerminado);
    expect(find.text('Detalle del libro'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Eliminar pide confirmación y vuelve a la lista', (tester) async {
    _pantallaAlta(tester);
    final repositorio = _RepositorioFalso(libros: [_libroDemo()]);
    await tester.pumpWidget(_crearApp(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.text('La sombra del viento').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar libro'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar libro?'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(repositorio._libros, isEmpty);
    expect(find.text('Tu biblioteca está vacía'), findsOneWidget);
  });
}

Libro _libroDemo() {
  return Libro(
    id: 1,
    titulo: 'La sombra del viento',
    autor: 'Carlos Ruiz Zafón',
    genero: 'Novela',
    anioPublicacion: 2001,
    estadoLectura: Libro.estadoLeyendo,
  );
}
