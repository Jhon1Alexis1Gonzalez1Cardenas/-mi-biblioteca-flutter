import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mi_biblioteca/data/libro_repository.dart';
import 'package:mi_biblioteca/models/libro.dart';
import 'package:mi_biblioteca/providers/libros_provider.dart';
import 'package:mi_biblioteca/screens/lista_libros_screen.dart';
import 'package:mi_biblioteca/theme/app_theme.dart';

import 'helpers/repositorio_falso.dart';

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
    await tester.pumpWidget(_crearApp(RepositorioFalso()));
    await tester.pumpAndSettle();

    expect(find.text('Tu biblioteca está vacía'), findsOneWidget);
    expect(find.text('Agregar libro'), findsOneWidget);
  });

  testWidgets('Lista los libros guardados', (tester) async {
    final repositorio = RepositorioFalso(
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
    expect(find.text('Leyendo'), findsWidgets);
  });

  testWidgets('Valida título y autor obligatorios al guardar', (tester) async {
    await tester.pumpWidget(_crearApp(RepositorioFalso()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Agregar libro'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Guardar libro'));
    await tester.pumpAndSettle();

    expect(find.text('El título es obligatorio'), findsOneWidget);
    expect(find.text('El autor es obligatorio'), findsOneWidget);
  });

  testWidgets('Guarda un libro nuevo y lo muestra en la lista', (tester) async {
    final repositorio = RepositorioFalso();
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

    expect(repositorio.libros, hasLength(1));
    expect(find.text('Nada'), findsWidgets);
    expect(find.text('Carmen Laforet'), findsOneWidget);
  });

  testWidgets('El detalle muestra los datos del libro', (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(RepositorioFalso(libros: [_libroDemo()])));
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
    final repositorio = RepositorioFalso(libros: [_libroDemo()]);
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

    expect(repositorio.libros.first.estadoLectura, Libro.estadoTerminado);
    expect(find.text('Detalle del libro'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Eliminar pide confirmación y vuelve a la lista', (tester) async {
    _pantallaAlta(tester);
    final repositorio = RepositorioFalso(libros: [_libroDemo()]);
    await tester.pumpWidget(_crearApp(repositorio));
    await tester.pumpAndSettle();

    await tester.tap(find.text('La sombra del viento').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Eliminar libro'));
    await tester.pumpAndSettle();

    expect(find.text('¿Eliminar libro?'), findsOneWidget);

    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(repositorio.libros, isEmpty);
    expect(find.text('Tu biblioteca está vacía'), findsOneWidget);
  });

  testWidgets('Busca libros por título desde el campo de búsqueda',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(_bibliotecaDemo()));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar por título o autor'),
      'sombra',
    );
    await tester.pumpAndSettle();

    expect(find.text('La sombra del viento'), findsWidgets);
    expect(find.text('Nada'), findsNothing);
    expect(find.text('1 libro'), findsOneWidget);
  });

  testWidgets('El chip de estado filtra y se combina con la búsqueda',
      (tester) async {
    _pantallaAlta(tester);
    await tester.pumpWidget(_crearApp(_bibliotecaDemo()));
    await tester.pumpAndSettle();

    final chipTerminado = find.byKey(const ValueKey('chip-filtro-Terminado'));
    await tester.ensureVisible(chipTerminado);
    await tester.pumpAndSettle();
    await tester.tap(chipTerminado);
    await tester.pumpAndSettle();

    expect(find.text('Nada'), findsWidgets);
    expect(find.text('La sombra del viento'), findsNothing);
    expect(find.text('1 libro'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Buscar por título o autor'),
      'sombra',
    );
    await tester.pumpAndSettle();

    expect(find.text('Sin resultados'), findsOneWidget);

    await tester.tap(find.text('Limpiar filtros'));
    await tester.pumpAndSettle();

    expect(find.text('La sombra del viento'), findsWidgets);
    expect(find.text('Nada'), findsWidgets);
  });
}

RepositorioFalso _bibliotecaDemo() {
  return RepositorioFalso(
    libros: [
      libroDePrueba(
        id: 1,
        titulo: 'La sombra del viento',
        autor: 'Carlos Ruiz Zafón',
        estadoLectura: Libro.estadoLeyendo,
      ),
      libroDePrueba(
        id: 2,
        titulo: 'Nada',
        autor: 'Carmen Laforet',
        anioPublicacion: 1945,
        estadoLectura: Libro.estadoTerminado,
      ),
    ],
  );
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
