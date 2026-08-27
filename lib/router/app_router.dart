import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ⭐ OPERACIONAL
import '../screens/operacional/operacional_index_screen.dart';
import '../screens/operacional/contato_list_screen.dart';
import '../screens/operacional/contato_unified_screen.dart';
import '../screens/operacional/empresa_list_screen.dart';
import '../screens/operacional/empresa_unified_screen.dart';

// ⭐ PROJETOS
import '../screens/projetos/projeto_list_screen.dart';
import '../screens/projetos/projeto_form_screen.dart';
import '../screens/projetos/projeto_detail_screen.dart';

// ⭐ GERAIS
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // ==========================================
    // ROTA DE LOGIN
    // ==========================================
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginScreen(),
      ),
    ),

    // ==========================================
    // ROTA HOME (DASHBOARD)
    // ==========================================
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(
        child: HomeScreen(),
      ),
    ),

    // ==========================================
    // ⭐ MÓDULO OPERACIONAL
    // ==========================================

    // Índice do Operacional
    GoRoute(
      path: '/operacional',
      name: 'operacional',
      pageBuilder: (context, state) => const MaterialPage(
        child: OperacionalIndexScreen(),
      ),
    ),

    // ⭐ CONTATOS (CORRIGIDO)
    GoRoute(
      path: '/operacional/contatos',
      name: 'contatos',
      pageBuilder: (context, state) => const MaterialPage(
        child: ContatoListScreen(),
      ),
    ),
    GoRoute(
      path: '/operacional/contato/novo',
      name: 'novo-contato',
      pageBuilder: (context, state) => const MaterialPage(
        child: ContatoUnifiedScreen(),
      ),
    ),
    GoRoute(
      path: '/operacional/contato/:id',
      name: 'editar-contato',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(
          child: ContatoUnifiedScreen(contatoId: id),
        );
      },
    ),

    // ⭐ EMPRESAS
    GoRoute(
      path: '/operacional/empresas',
      name: 'empresas',
      pageBuilder: (context, state) => const MaterialPage(
        child: EmpresaListScreen(),
      ),
    ),
    GoRoute(
      path: '/operacional/empresa/novo',
      name: 'nova-empresa',
      pageBuilder: (context, state) => const MaterialPage(
        child: EmpresaUnifiedScreen(),
      ),
    ),
    GoRoute(
      path: '/operacional/empresa/:id',
      name: 'editar-empresa',
      pageBuilder: (context, state) {
        final id = state.pathParameters['id']!;
        return MaterialPage(
          child: EmpresaUnifiedScreen(empresaId: id),
        );
      },
    ),

    // ==========================================
    // ⭐ MÓDULO PROJETOS
    // ==========================================
    GoRoute(
      path: '/projetos',
      name: 'projetos',
      pageBuilder: (context, state) => const MaterialPage(
        child: ProjetoListScreen(),
      ),
      routes: [
        GoRoute(
          path: 'novo',
          name: 'novo-projeto',
          pageBuilder: (context, state) => const MaterialPage(
            child: ProjetoFormScreen(),
          ),
        ),
        GoRoute(
          path: 'editar/:id',
          name: 'editar-projeto',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ProjetoFormScreen(projetoId: id),
            );
          },
        ),
        GoRoute(
          path: ':id',
          name: 'detalhe-projeto',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ProjetoDetailScreen(projetoId: id),
            );
          },
        ),
      ],
    ),
  ],
);