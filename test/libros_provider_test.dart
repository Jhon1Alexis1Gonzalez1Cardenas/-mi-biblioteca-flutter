import 'package:flutter_test/flutter_test.dart';
import 'package:mi_biblioteca/models/libro.dart';
import 'package:mi_biblioteca/providers/libros_provider.dart';

import 'helpers/repositorio_falso.dart';

void main() {
  late RepositorioFalso repositorio;
  late LibrosProvider provider;

  List<Libro> librosDemo() => [
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
        libroDePrueba(
          id: 3,
          titulo: 'El infinito en un junco',
          autor: 'Irene Vallejo',
          genero: 'Ensayo',
          anioPublicacion: 2019,
          estadoLectura: Libro.estadoPendiente,
        ),
        libroDePrueba(
          id: 4,
          titulo: 'Los detectives salvajes',
          autor: 'Roberto Bolaño',
          anioPublicacion: 1998,
          estadoLectura: Libro.estadoPendiente,
        ),
      ];

  setUp(() async {
    repositorio = RepositorioFalso(libros: librosDemo());
    provider = LibrosProvider(repository: repositorio);
    await provider.cargarLibros();
  });

  List<String> titulos() =>
      provider.librosFiltrados.map((libro) => libro.titulo).toList();

  test('Sin búsqueda ni filtro muestra todos los libros', () {
    expect(provider.librosFiltrados, hasLength(4));
    expect(provider.hayFiltros, isFalse);
  });

  test('Busca por título sin distinguir mayúsculas ni tildes', () {
    provider.buscar('SOMBRA');
    expect(titulos(), ['La sombra del viento']);

    provider.buscar('juncó');
    expect(titulos(), ['El infinito en un junco']);
  });

  test('Busca por autor sin distinguir mayúsculas ni tildes', () {
    provider.buscar('zafon');
    expect(titulos(), ['La sombra del viento']);

    provider.buscar('BOLAÑO');
    expect(titulos(), ['Los detectives salvajes']);
  });

  test('Filtra por estado de lectura', () {
    provider.filtrarPorEstado(Libro.estadoPendiente);
    expect(titulos(), ['El infinito en un junco', 'Los detectives salvajes']);

    provider.filtrarPorEstado(Libro.estadoTerminado);
    expect(titulos(), ['Nada']);

    provider.filtrarPorEstado(null);
    expect(provider.librosFiltrados, hasLength(4));
  });

  test('Combina búsqueda y filtro de estado', () {
    provider.buscar('nada');
    provider.filtrarPorEstado(Libro.estadoTerminado);
    expect(titulos(), ['Nada']);
    expect(provider.sinResultados, isFalse);

    provider.filtrarPorEstado(Libro.estadoPendiente);
    expect(titulos(), isEmpty);
    expect(provider.sinResultados, isTrue);
  });

  test('Limpiar filtros restablece la lista completa', () {
    provider.buscar('nada');
    provider.filtrarPorEstado(Libro.estadoPendiente);

    provider.limpiarFiltros();

    expect(provider.busqueda, isEmpty);
    expect(provider.filtroEstado, isNull);
    expect(provider.librosFiltrados, hasLength(4));
  });

  test('La lista filtrada se mantiene sincronizada al agregar', () async {
    provider.filtrarPorEstado(Libro.estadoTerminado);

    await provider.agregarLibro(
      libroDePrueba(
        id: 0,
        titulo: 'Cien años de soledad',
        autor: 'Gabriel García Márquez',
        estadoLectura: Libro.estadoTerminado,
      ),
    );

    expect(titulos(), ['Cien años de soledad', 'Nada']);
  });

  test('La lista filtrada se mantiene sincronizada al editar', () async {
    provider.filtrarPorEstado(Libro.estadoPendiente);
    expect(titulos(), hasLength(2));

    final pendiente = provider.librosFiltrados.first;
    await provider.actualizarLibro(
      pendiente.copyWith(estadoLectura: Libro.estadoTerminado),
    );

    expect(titulos(), hasLength(1));
  });

  test('La lista filtrada se mantiene sincronizada al eliminar', () async {
    provider.buscar('nada');
    expect(titulos(), ['Nada']);

    await provider.eliminarLibro(2);

    expect(titulos(), isEmpty);
    expect(provider.sinResultados, isTrue);
  });
}
