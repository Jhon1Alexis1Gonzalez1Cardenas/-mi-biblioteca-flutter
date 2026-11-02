import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/mensaje_chat.dart';
import '../providers/chat_provider.dart';
import '../services/chat_service.dart';
import '../services/configuracion_ia.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({
    super.key,
    this.chatService,
    this.configuracion,
    this.nombreUsuario,
  });

  final ChatService? chatService;
  final ConfiguracionIA? configuracion;
  final String? nombreUsuario;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ChatProvider(service: chatService, configuracion: configuracion)
            ..cargarConfiguracion(),
      child: _ChatContenido(nombreUsuario: nombreUsuario),
    );
  }
}

class _ChatContenido extends StatefulWidget {
  const _ChatContenido({this.nombreUsuario});

  final String? nombreUsuario;

  @override
  State<_ChatContenido> createState() => _ChatContenidoState();
}

class _ChatContenidoState extends State<_ChatContenido> {
  final _textoController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _textoController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _desplazarAlFinal() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _enviar([String? textoSugerido]) async {
    final texto = textoSugerido ?? _textoController.text;
    if (texto.trim().isEmpty) return;

    _textoController.clear();
    FocusScope.of(context).unfocus();

    final provider = context.read<ChatProvider>();
    await provider.enviar(texto);
    if (!mounted) return;
    _desplazarAlFinal();
  }

  Future<void> _reintentar() async {
    await context.read<ChatProvider>().reintentar();
    if (!mounted) return;
    _desplazarAlFinal();
  }

  Future<void> _abrirAjustesServidor() async {
    final provider = context.read<ChatProvider>();

    final aviso = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoServidorIA(
        provider: provider,
        urlActual: provider.urlServidor,
      ),
    );

    if (aviso != null && mounted) _mostrarAviso(aviso);
  }

  void _mostrarAviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _EncabezadoChat(
              onVolver: () => Navigator.of(context).pop(),
              onAjustes: _abrirAjustesServidor,
            ),
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 14),
                      child: Text(
                        'Hoy',
                        style: TextStyle(
                          color: AppTheme.textMuted,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (!chat.tieneMensajes) ...[
                    _Bienvenida(
                      nombreUsuario: widget.nombreUsuario,
                      onSugerencia: _enviar,
                    ),
                    const SizedBox(height: 4),
                  ],
                  ...chat.mensajes.map((mensaje) => _Burbuja(mensaje: mensaje)),
                  if (chat.enviando) const _IndicadorEscribiendo(),
                  if (chat.error != null)
                    _BurbujaError(
                      mensaje: chat.error!,
                      onReintentar: _reintentar,
                    ),
                ],
              ),
            ),
            _CampoEnvio(
              controller: _textoController,
              habilitado: !chat.enviando,
              onEnviar: _enviar,
            ),
          ],
        ),
      ),
    );
  }
}

class _EncabezadoChat extends StatelessWidget {
  const _EncabezadoChat({required this.onVolver, required this.onAjustes});

  final VoidCallback onVolver;
  final VoidCallback onAjustes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          Material(
            color: AppTheme.surfaceWhite,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onVolver,
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Icon(
                  Icons.arrow_back,
                  color: AppTheme.textDark,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asistente IA',
                  style: TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tu compañero de lectura',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Servidor de IA',
            onPressed: onAjustes,
            icon: const Icon(
              Icons.settings_outlined,
              color: AppTheme.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Bienvenida extends StatelessWidget {
  const _Bienvenida({required this.onSugerencia, this.nombreUsuario});

  final ValueChanged<String> onSugerencia;
  final String? nombreUsuario;

  static const List<String> _sugerencias = [
    'Recomiéndame un libro',
    'Resume un libro',
    '¿Qué leo después?',
  ];

  @override
  Widget build(BuildContext context) {
    final saludo = nombreUsuario == null || nombreUsuario!.trim().isEmpty
        ? '¡Hola! Soy tu compañero de lectura.'
        : '¡Hola, ${nombreUsuario!.trim()}! Soy tu compañero de lectura.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceWhite,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Text(
            '$saludo Puedo recomendarte libros, ayudarte con un resumen '
            'o descubrir contigo qué leer después.',
            style: const TextStyle(
              color: AppTheme.textDark,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Puedes empezar con una pregunta',
          style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 10),
        for (final sugerencia in _sugerencias) ...[
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton(
              onPressed: () => onSugerencia(sugerencia),
              style: OutlinedButton.styleFrom(
                backgroundColor: AppTheme.surfaceWhite,
                foregroundColor: AppTheme.primaryColor,
                side: const BorderSide(color: Color(0xFFD9D3E3)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: Text(sugerencia),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _Burbuja extends StatelessWidget {
  const _Burbuja({required this.mensaje});

  final MensajeChat mensaje;

  @override
  Widget build(BuildContext context) {
    final esUsuario = mensaje.esDelUsuario;

    return Align(
      alignment: esUsuario ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: esUsuario ? AppTheme.primaryColor : AppTheme.surfaceWhite,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(esUsuario ? 16 : 4),
            topRight: Radius.circular(esUsuario ? 4 : 16),
            bottomLeft: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
        ),
        child: Text(
          mensaje.contenido,
          style: TextStyle(
            color: esUsuario ? Colors.white : AppTheme.textDark,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _IndicadorEscribiendo extends StatelessWidget {
  const _IndicadorEscribiendo();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _Punto(),
            SizedBox(width: 4),
            _Punto(opacidad: 0.6),
            SizedBox(width: 4),
            _Punto(opacidad: 0.3),
            SizedBox(width: 8),
            Text(
              'escribiendo...',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _Punto extends StatelessWidget {
  const _Punto({this.opacidad = 1});

  final double opacidad;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: opacidad),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _BurbujaError extends StatelessWidget {
  const _BurbujaError({required this.mensaje, required this.onReintentar});

  final String mensaje;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.sizeOf(context).width * 0.78,
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              mensaje,
              style: const TextStyle(
                color: AppTheme.textDark,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            TextButton(
              onPressed: onReintentar,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text(
                'Reintentar',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoEnvio extends StatelessWidget {
  const _CampoEnvio({
    required this.controller,
    required this.habilitado,
    required this.onEnviar,
  });

  final TextEditingController controller;
  final bool habilitado;
  final VoidCallback onEnviar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceWhite,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: controller,
                enabled: habilitado,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onEnviar(),
                decoration: const InputDecoration(
                  hintText: 'Escribe tu pregunta...',
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: habilitado ? AppTheme.primaryColor : AppTheme.textMuted,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: habilitado ? onEnviar : null,
              child: const Padding(
                padding: EdgeInsets.all(13),
                child: Icon(Icons.arrow_upward, color: Colors.white, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para cambiar la URL del servidor de IA.
///
/// Es un widget con estado propio para que el controlador del campo de texto
/// se libere cuando el diálogo ya salió del árbol.
class _DialogoServidorIA extends StatefulWidget {
  const _DialogoServidorIA({required this.provider, required this.urlActual});

  final ChatProvider provider;
  final String urlActual;

  @override
  State<_DialogoServidorIA> createState() => _DialogoServidorIAState();
}

class _DialogoServidorIAState extends State<_DialogoServidorIA> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.urlActual);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final guardado = await widget.provider.guardarUrlServidor(_controller.text);
    if (!mounted || !guardado) return;

    Navigator.of(context).pop('Servidor guardado');
  }

  Future<void> _restablecer() async {
    await widget.provider.restablecerUrlServidor();
    if (!mounted) return;

    Navigator.of(context).pop('Servidor restablecido al valor por defecto');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Servidor de IA'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dirección donde corre Ollama en tu computador.',
              style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.url,
              autocorrect: false,
              decoration: const InputDecoration(
                hintText: ConfiguracionIA.urlPorDefecto,
                helperText: 'Debe empezar por http:// o https://',
              ),
              validator: (valor) => ConfiguracionIA.esUrlValida(valor ?? '')
                  ? null
                  : 'Debe empezar por http:// o https://',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _restablecer, child: const Text('Restablecer')),
        FilledButton(onPressed: _guardar, child: const Text('Guardar')),
      ],
    );
  }
}
