import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'config/supabase_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: '.env');
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    publishableKey: SupabaseConfig.anonKey,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SocialFlow - Teste',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialFlow - Teste'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              '✅ App funcionando!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Supabase URL: ${SupabaseConfig.url}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            Text(
              'Status: ${Supabase.instance.client.auth.currentSession != null ? "Autenticado" : "Não autenticado"}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Teste de navegação
              },
              child: const Text('Teste OK'),
            ),
          ],
        ),
      ),
    );
  }
}
