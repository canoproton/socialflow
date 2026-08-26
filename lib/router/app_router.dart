import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/projetos/projeto_provider.dart';
import '../screens/projetos/projeto_list_screen.dart';
import '../screens/projetos/projeto_form_screen.dart';
import '../screens/projetos/projeto_detail_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';  // ← Adicione esta importação

final GoRouter appRouter = GoRouter(
  // ⭐ ALTERADO: initialLocation agora é '/login'
  initialLocation: '/login',
  
  routes: [
    // ⭐ ROTA DE LOGIN (PRIMEIRA TELA)
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginScreen(),
      ),
    ),
    
    // ⭐ ROTA HOME (APÓS LOGIN)
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(
        child: HomeScreen(),
      ),
    ),
    
    // ⭐ MÓDULO PROJETOS (ACESSADO PELO MENU)
    GoRoute(
      path: '/projetos',
      name: 'projetos',
      pageBuilder: (context, state) => MaterialPage(
        child: ChangeNotifierProvider(
          create: (_) => ProjetoProvider(),
          child: const ProjetoListScreen(),
        ),
      ),
      routes: [
        GoRoute(
          path: 'novo',
          name: 'novo-projeto',
          pageBuilder: (context, state) => MaterialPage(
            child: ChangeNotifierProvider(
              create: (_) => ProjetoProvider(),
              child: const ProjetoFormScreen(),
            ),
          ),
        ),
        GoRoute(
          path: 'editar/:id',
          name: 'editar-projeto',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ChangeNotifierProvider(
                create: (_) => ProjetoProvider(),
                child: ProjetoFormScreen(projetoId: id),
              ),
            );
          },
        ),
        GoRoute(
          path: ':id',
          name: 'detalhe-projeto',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ChangeNotifierProvider(
                create: (_) => ProjetoProvider(),
                child: ProjetoDetailScreen(projetoId: id),
              ),
            );
          },
        ),
      ],
    ),
  ],
);