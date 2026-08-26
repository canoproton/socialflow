/// ============================================
/// ROTAS DO APLICATIVO
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/projetos/projeto_provider.dart';
import '../screens/projetos/projeto_list_screen.dart';
import '../screens/projetos/projeto_form_screen.dart';
import '../screens/projetos/projeto_detail_screen.dart';
import '../screens/home/home_screen.dart'; // Assumindo que existe

// ============================================
// CONFIGURAÇÃO DO ROUTER
// ============================================

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ==========================================
    // ROTA PRINCIPAL
    // ==========================================
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => MaterialPage(
        child: const HomeScreen(),
      ),
    ),

    // ==========================================
    // ROTAS DO MÓDULO PROJETOS
    // ==========================================
    
    /// Lista de Projetos
    GoRoute(
      path: '/projetos',
      name: 'projetos',
      pageBuilder: (context, state) => MaterialPage(
        child: ChangeNotifierProvider(
          create: (_) => ProjetoProvider(),
          child: const ProjetoListScreen(),
        ),
      ),
    ),

    /// Novo Projeto
    GoRoute(
      path: '/projetos/novo',
      name: 'novo-projeto',
      pageBuilder: (context, state) => MaterialPage(
        child: ChangeNotifierProvider(
          create: (_) => ProjetoProvider(),
          child: const ProjetoFormScreen(),
        ),
      ),
    ),

    /// Editar Projeto
    GoRoute(
      path: '/projetos/editar/:id',
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

    /// Detalhes do Projeto
    GoRoute(
      path: '/projetos/:id',
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

  // ==========================================
  // PÁGINA DE ERRO
  // ==========================================
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Página não encontrada',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          Text(
            state.error?.message ?? 'Erro ao carregar página',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Ir para Início'),
          ),
        ],
      ),
    ),
  ),
);

// ============================================
// EXTENSIONS PARA NAVEGAÇÃO (OPCIONAL)
// ============================================

extension GoRouterExtensions on BuildContext {
  /// Navegar para Lista de Projetos
  void goToProjetos() => go('/projetos');
  
  /// Navegar para Novo Projeto
  void goToNovoProjeto() => go('/projetos/novo');
  
  /// Navegar para Editar Projeto
  void goToEditarProjeto(String id) => go('/projetos/editar/$id');
  
  /// Navegar para Detalhes do Projeto
  void goToDetalhesProjeto(String id) => go('/projetos/$id');
  
  /// Voltar para página anterior
  void goBack() => pop();
}