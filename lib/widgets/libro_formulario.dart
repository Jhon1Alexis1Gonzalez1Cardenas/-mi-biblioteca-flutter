import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/libro.dart';
import '../theme/app_theme.dart';
import 'selector_estado.dart';

/// Formulario compartido por las pantallas de agregar y editar libro.
class LibroFormulario extends StatefulWidget {
  const LibroFormulario({
    super.key,
    required this.tituloEncabezado,
    required this.subtituloEncabezado,
    required this.textoGuardar,
    required this.textoSecundario,
    required this.notaPie,
    required this.onGuardar,
    this.libroInicial,
    this.encabezadoExtra,
    this.alGuardarExitoso,
  });

  final String tituloEncabezado;
  final String subtituloEncabezado;
  final String textoGuardar;
  final String textoSecundario;
  final String notaPie;
  final Libro? libroInicial;
  final Widget? encabezadoExtra;
  final Future<bool> Function(Libro libro) onGuardar;
  final void Function(BuildContext context)? alGuardarExitoso;

  @override
  State<LibroFormulario> createState() => _LibroFormularioState();
}

class _LibroFormularioState extends State<LibroFormulario> {
  static const List<String> _generos = [
    'Novela',
    'Cuento',
    'Ensayo',
    'Poesía',
    'Ciencia ficción',
    'Fantasía',
    'Historia',
    'Biografía',
    'Otro',
  ];

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _tituloController;
  late final TextEditingController _autorController;
  late final TextEditingController _anioController;

  String? _genero;
  late String _estadoLectura;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final libro = widget.libroInicial;
    _tituloController = TextEditingController(text: libro?.titulo ?? '');
    _autorController = TextEditingController(text: libro?.autor ?? '');
    _anioController = TextEditingController(
      text: libro == null || libro.anioPublicacion <= 0
          ? ''
          : '${libro.anioPublicacion}',
    );
    _genero = _generos.contains(libro?.genero) ? libro!.genero : null;
    _estadoLectura = libro?.estadoLectura ?? Libro.estadoPendiente;
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _anioController.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final libro = Libro(
      id: widget.libroInicial?.id,
      titulo: _tituloController.text.trim(),
      autor: _autorController.text.trim(),
      genero: _genero ?? widget.libroInicial?.genero ?? '',
      anioPublicacion: int.tryParse(_anioController.text.trim()) ??
          widget.libroInicial?.anioPublicacion ??
          DateTime.now().year,
      estadoLectura: _estadoLectura,
    );

    final guardado = await widget.onGuardar(libro);
    if (!mounted) return;

    if (guardado) {
      widget.alGuardarExitoso?.call(context);
    } else {
      setState(() => _guardando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo guardar el libro. Intenta de nuevo.'),
        ),
      );
    }
  }

  String? _validarAnio(String? valor) {
    final texto = valor?.trim() ?? '';
    if (texto.isEmpty) return null;
    final anio = int.tryParse(texto);
    if (anio == null) return 'Escribe un año válido';
    if (anio < 1 || anio > DateTime.now().year) {
      return 'Entre 1 y ${DateTime.now().year}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              _Encabezado(
                titulo: widget.tituloEncabezado,
                subtitulo: widget.subtituloEncabezado,
                onVolver: () => Navigator.of(context).pop(),
              ),
              if (widget.encabezadoExtra != null) ...[
                const SizedBox(height: 20),
                widget.encabezadoExtra!,
              ],
              const SizedBox(height: 24),
              const _Etiqueta('Título'),
              TextFormField(
                controller: _tituloController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Escribe el título',
                  prefixIcon: Icon(Icons.menu_book_outlined),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El título es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              const _Etiqueta('Autor'),
              TextFormField(
                controller: _autorController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  hintText: 'Nombre del autor o autora',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'El autor es obligatorio'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Etiqueta('Género'),
                        DropdownButtonFormField<String>(
                          initialValue: _genero,
                          isExpanded: true,
                          hint: const Text('Seleccionar'),
                          decoration: const InputDecoration(),
                          items: _generos
                              .map(
                                (genero) => DropdownMenuItem(
                                  value: genero,
                                  child: Text(genero),
                                ),
                              )
                              .toList(),
                          onChanged: (valor) => setState(() => _genero = valor),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Etiqueta('Año'),
                        TextFormField(
                          controller: _anioController,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(4),
                          ],
                          decoration:
                              const InputDecoration(hintText: '2026'),
                          validator: _validarAnio,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _Etiqueta('Estado de lectura'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: Libro.estados
                    .map(
                      (estado) => SelectorEstado(
                        estado: estado,
                        seleccionado: estado == _estadoLectura,
                        onTap: () => setState(() => _estadoLectura = estado),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_guardando ? 'Guardando...' : widget.textoGuardar),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed:
                    _guardando ? null : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.textoSecundario),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  widget.notaPie,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Encabezado extends StatelessWidget {
  const _Encabezado({
    required this.titulo,
    required this.subtitulo,
    required this.onVolver,
  });

  final String titulo;
  final String subtitulo;
  final VoidCallback onVolver;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: AppTheme.surfaceWhite,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onVolver,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.arrow_back, color: AppTheme.textDark, size: 22),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(
                  color: AppTheme.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitulo,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
