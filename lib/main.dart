import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/operacional/contato_provider.dart';
import 'providers/operacional/empresa_provider.dart';
import 'providers/projetos/projeto_provider.dart';
import 'providers/alocacao_provider.dart'; // ✅ DEVE ESTAR IMPORTADO
import 'router/app_router.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://omtgcvoxqzlsbrxvwgik.supabase.co',
      anonKey: 'sb_publishable_0tGIXruer3GCFJVDkVpodw_GPqJtWbC', // ← SUA CHAVE COMPLETA
    );
    debugPrint('✅ Supabase conectado!');
  } catch (e) {
    debugPrint('❌ Erro ao conectar Supabase: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ⭐ PROVIDERS DO OPERACIONAL
        ChangeNotifierProvider(create: (_) => EmpresaProvider()),
        ChangeNotifierProvider(create: (_) => ContatoProvider()),
        // ⭐ PROVIDER DO PROJETOS
        ChangeNotifierProvider(create: (_) => ProjetoProvider()),
        // ⭐ PROVIDER DA ALOCAÇÃO
        ChangeNotifierProvider(create: (_) => AlocacaoProvider()),
      ],
      child: MaterialApp.router(
        title: 'SocialFlow',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}