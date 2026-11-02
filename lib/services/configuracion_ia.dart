import 'package:shared_preferences/shared_preferences.dart';

/// Guarda la configuración del servidor de IA (persistente en el dispositivo).
class ConfiguracionIA {
  ConfiguracionIA({this.preferencias});

  static const String urlPorDefecto = 'http://10.0.2.2:11434';
  static const String modelo = 'qwen2.5:3b';
  static const String _claveUrl = 'url_servidor_ia';

  final SharedPreferences? preferencias;

  Future<SharedPreferences> get _prefs async =>
      preferencias ?? await SharedPreferences.getInstance();

  Future<String> obtenerUrl() async {
    final prefs = await _prefs;
    final url = prefs.getString(_claveUrl);
    return (url == null || url.trim().isEmpty) ? urlPorDefecto : url;
  }

  Future<void> guardarUrl(String url) async {
    final prefs = await _prefs;
    await prefs.setString(_claveUrl, url.trim());
  }

  Future<void> restablecerUrl() async {
    final prefs = await _prefs;
    await prefs.remove(_claveUrl);
  }

  /// Una URL válida debe empezar por http:// o https://.
  static bool esUrlValida(String url) {
    final texto = url.trim().toLowerCase();
    return texto.startsWith('http://') || texto.startsWith('https://');
  }
}
