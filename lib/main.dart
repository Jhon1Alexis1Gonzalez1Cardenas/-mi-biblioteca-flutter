import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/libros_provider.dart';
import 'screens/lista_libros_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MiBibliotecaApp());
}

class MiBibliotecaApp extends StatelessWidget {
  const MiBibliotecaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LibrosProvider()),
      ],
      child: MaterialApp(
        title: 'Mi Biblioteca',
        theme: AppTheme.lightTheme,
        home: const ListaLibrosScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
