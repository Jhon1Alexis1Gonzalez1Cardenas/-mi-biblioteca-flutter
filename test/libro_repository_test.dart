import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/data/database_helper.dart';
import 'package:mi_biblioteca/data/libro_repository.dart';
import 'package:mi_biblioteca/models/libro.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  late DatabaseHelper helper;
  late LibroRepository repositorio;

  setUp(() {
    helper = DatabaseHelper(
      fabrica: databaseFactoryFfi,
      rutaBaseDeDatos: inMemoryDatabasePath,
    );
    repositorio = LibroRepository(databaseHelper: helper);
  });

  tearDown(() async {
    await helper.cerrar();
  });

  Libro libroDePrueba({
    String titulo = 'La sombra del viento',
    String autor = 'Carlos Ruiz Zafón',
    String genero = 'Novela',
    int anio = 2001,
    String estado = Libro.estadoLeyendo,
  }) {
    return Libro(
      titulo: titulo,
      autor: autor,
      genero: genero,
      anioPublicacion: anio,
      estadoLectura: estado,
    );
  }

  test('insertar y listar devuelve los libros guardados', () async {
    final guardado = await repositorio.insertar(libroDePrueba());

    expect(guardado.id, isNotNull);

    final libros = await repositorio.listar();
    expect(libros, hasLength(1));
    expect(libros.first.titulo, 'La sombra del viento');
    expect(libros.first.autor, 'Carlos Ruiz Zafón');
  });

  test('obtenerPorId devuelve el libro o null si no existe', () async {
    final guardado = await repositorio.insertar(libroDePrueba());

    final encontrado = await repositorio.obtenerPorId(guardado.id!);
    expect(encontrado, isNotNull);
    expect(encontrado!.titulo, 'La sombra del viento');

    final inexistente = await repositorio.obtenerPorId(9999);
    expect(inexistente, isNull);
  });

  test('actualizar modifica los datos y el estado de lectura', () async {
    final guardado = await repositorio.insertar(libroDePrueba());

    final actualizado = await repositorio.actualizar(
      guardado.copyWith(
        titulo: 'Nada',
        autor: 'Carmen Laforet',
        genero: 'Novela',
        anioPublicacion: 1945,
        estadoLectura: Libro.estadoTerminado,
      ),
    );

    expect(actualizado, isTrue);

    final enBase = await repositorio.obtenerPorId(guardado.id!);
    expect(enBase!.titulo, 'Nada');
    expect(enBase.autor, 'Carmen Laforet');
    expect(enBase.anioPublicacion, 1945);
    expect(enBase.estadoLectura, Libro.estadoTerminado);

    final libros = await repositorio.listar();
    expect(libros, hasLength(1));
  });

  test('eliminar borra el libro y devuelve false si ya no existe', () async {
    final guardado = await repositorio.insertar(libroDePrueba());
    final otro = await repositorio.insertar(
      libroDePrueba(titulo: 'El infinito en un junco'),
    );

    final eliminado = await repositorio.eliminar(guardado.id!);
    expect(eliminado, isTrue);

    final libros = await repositorio.listar();
    expect(libros, hasLength(1));
    expect(libros.first.id, otro.id);

    final repetido = await repositorio.eliminar(guardado.id!);
    expect(repetido, isFalse);
  });

  test('listar sin libros devuelve una lista vacía', () async {
    expect(await repositorio.listar(), isEmpty);
  });

  test('listar devuelve los libros más recientes primero', () async {
    final primero = await repositorio.insertar(
      libroDePrueba(titulo: 'Primero'),
    );
    final segundo = await repositorio.insertar(
      libroDePrueba(titulo: 'Segundo'),
    );

    final libros = await repositorio.listar();

    expect(libros.map((libro) => libro.id), [segundo.id, primero.id]);
  });

  test('los libros guardados se pueden buscar por título o autor', () async {
    await repositorio.insertar(
      libroDePrueba(titulo: 'La sombra del viento', autor: 'Carlos Ruiz Zafón'),
    );
    await repositorio.insertar(
      libroDePrueba(titulo: 'Nada', autor: 'Carmen Laforet'),
    );

    final libros = await repositorio.listar();

    final porTitulo = libros.where(
      (libro) => libro.titulo.toLowerCase().contains('sombra'),
    );
    final porAutor = libros.where(
      (libro) => libro.autor.toLowerCase().contains('laforet'),
    );

    expect(porTitulo, hasLength(1));
    expect(porTitulo.first.autor, 'Carlos Ruiz Zafón');
    expect(porAutor, hasLength(1));
    expect(porAutor.first.titulo, 'Nada');
  });
}
