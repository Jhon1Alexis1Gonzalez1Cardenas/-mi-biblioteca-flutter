class Libro {
  static const String estadoPendiente = 'Pendiente';
  static const String estadoLeyendo = 'Leyendo';
  static const String estadoTerminado = 'Terminado';
  static const List<String> estados = [
    estadoPendiente,
    estadoLeyendo,
    estadoTerminado,
  ];

  final int? id;
  final String titulo;
  final String autor;
  final String genero;
  final int anioPublicacion;
  final String estadoLectura; // 'Pendiente' | 'Leyendo' | 'Terminado'

  Libro({
    this.id,
    required this.titulo,
    required this.autor,
    required this.genero,
    required this.anioPublicacion,
    required this.estadoLectura,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'autor': autor,
      'genero': genero,
      'anioPublicacion': anioPublicacion,
      'estadoLectura': estadoLectura,
    };
  }

  factory Libro.fromMap(Map<String, dynamic> map) {
    return Libro(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      autor: map['autor'] as String,
      genero: map['genero'] as String,
      anioPublicacion: map['anioPublicacion'] as int,
      estadoLectura: map['estadoLectura'] as String,
    );
  }

  Libro copyWith({
    int? id,
    String? titulo,
    String? autor,
    String? genero,
    int? anioPublicacion,
    String? estadoLectura,
  }) {
    return Libro(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      autor: autor ?? this.autor,
      genero: genero ?? this.genero,
      anioPublicacion: anioPublicacion ?? this.anioPublicacion,
      estadoLectura: estadoLectura ?? this.estadoLectura,
    );
  }

  /// Progreso estimado según el estado; el modelo no guarda páginas leídas.
  double get progresoLectura => switch (estadoLectura) {
    estadoTerminado => 1,
    estadoLeyendo => 0.5,
    _ => 0,
  };

  int get porcentajeLectura => (progresoLectura * 100).round();
}
