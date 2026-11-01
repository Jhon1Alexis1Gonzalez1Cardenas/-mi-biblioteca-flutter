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
  Future<Libro> insertar(Libro libro) async {
    final guardado = libro.copyWith(id: _siguienteId++);
    _libros.insert(0, guardado);
    return guardado;
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
}
