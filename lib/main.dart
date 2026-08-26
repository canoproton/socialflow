import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // 🔹 SUBSTITUA PELAS SUAS CREDENCIAIS
    await Supabase.initialize(
      url: 'https://seu-projeto.supabase.co',
      anonKey: 'sua-chave-anon',
    );
    print('✅ Supabase conectado!');
  } catch (e) {
    print('❌ Erro: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'SocialFlow',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}