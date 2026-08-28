import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ⭐ OPERACIONAL
import '../screens/operacional/empresa_list_screen.dart';
import '../screens/operacional/empresa_unified_screen.dart';
import '../screens/operacional/contato_list_screen.dart';
import '../screens/operacional/contato_unified_screen.dart';

// ⭐ IMPORTS DO MÓDULO PROJETOS (completos)
import '../screens/projetos/projeto_list_screen.dart';
import '../screens/projetos/projeto_form_screen.dart';
import '../screens/projetos/projeto_detail_screen.dart';
import '../screens/projetos/fontes_base_list_screen.dart';
import '../screens/projetos/fontes_base_form_screen.dart';
import '../screens/projetos/contra_partida_list_screen.dart';
import '../screens/projetos/contra_partida_form_screen.dart';

// ⭐ GERAIS
import '../screens/auth/login_screen.dart';
import '../screens/home/home_screen.dart';
import '../services/debug_service.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // Login
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(
        child: LoginScreen(),
      ),
    ),

    // Home
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(
        child: HomeScreen(),
      ),
    ),

    // ⭐ OPERACIONAL - EMPRESAS
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
        DebugService.navigation(
          '${state.matchedLocation}',
          '${state.name}',
          params: state.pathParameters,
       );
        final id = state.pathParameters['id']!;
        return MaterialPage(
          child: EmpresaUnifiedScreen(empresaId: id),
        );
      },
    ),

    // ⭐ OPERACIONAL - CONTATOS
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
        DebugService.navigation(
          '${state.matchedLocation}',
          '${state.name}',
          params: state.pathParameters,
        );
        final id = state.pathParameters['id']!;
        return MaterialPage(
          child: ContatoUnifiedScreen(contatoId: id),
        );
      },
    ),

    // ⭐ PROJETOS
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
            DebugService.navigation(
              '${state.matchedLocation}',
              '${state.name}',
              params: state.pathParameters,
            );          
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
            DebugService.navigation(
              '${state.matchedLocation}',
              '${state.name}',
              params: state.pathParameters,
            );
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ProjetoDetailScreen(projetoId: id),
            );
          },
        ),
        // ==========================================
        // FONTES DE RECURSOS (Regra 7)
        // ==========================================
        GoRoute(
          path: '/projetos/fontes',
          name: 'fontes-recursos',
          pageBuilder: (context, state) => const MaterialPage(
            child: FontesBaseListScreen(),
          ),
        ),
        GoRoute(
          path: '/projetos/fontes/novo',
          name: 'nova-fonte',
          pageBuilder: (context, state) => const MaterialPage(
            child: FontesBaseFormScreen(),
          ),
        ),
        GoRoute(
          path: '/projetos/fontes/editar/:id',
          name: 'editar-fonte',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: FontesBaseFormScreen(fonteId: id),
            );
          },
        ),
        // ==========================================
        // CONTRA PARTIDAS (Regra 11)
        // ==========================================
        GoRoute(
          path: '/projetos/contra-partidas',
          name: 'contra-partidas',
          pageBuilder: (context, state) => const MaterialPage(
            child: ContraPartidaListScreen(),
          ),
        ),
        GoRoute(
          path: '/projetos/contra-partida/novo',
          name: 'nova-contra-partida',
          pageBuilder: (context, state) => const MaterialPage(
            child: ContraPartidaFormScreen(),
          ),
        ),
        GoRoute(
          path: '/projetos/contra-partida/editar/:id',
          name: 'editar-contra-partida',
          pageBuilder: (context, state) {
            final id = state.pathParameters['id']!;
            return MaterialPage(
              child: ContraPartidaFormScreen(contraPartidaId: id),
            );
          },
        ),
      ],
    ),
  ],
);