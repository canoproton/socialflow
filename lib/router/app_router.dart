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
import '../screens/projetos/fontes_base_list_screen.dart';
import '../screens/projetos/fontes_base_form_screen.dart';
import '../screens/projetos/fontes_base_detail_screen.dart';
import '../screens/projetos/fonte_alocacao_list_screen.dart';
import '../screens/projetos/fonte_alocacao_form_screen.dart';
import '../screens/projetos/contra_partida_list_screen.dart';
import '../screens/projetos/contra_partida_form_screen.dart';
import '../screens/alocacoes/alocacao_pesquisa_screen.dart';

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

    // CONTATOS
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

    // EMPRESAS
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
    
    // PROJETOS - ROTA PRINCIPAL
    GoRoute(
      path: '/projetos',
      name: 'projetos',
      pageBuilder: (context, state) => const MaterialPage(
        child: ProjetoListScreen(),
      ),
      routes: [
        // NOVO PROJETO
        GoRoute(
          path: 'novo',
          name: 'novo-projeto',
          pageBuilder: (context, state) => const MaterialPage(
            child: ProjetoFormScreen(),
          ),
        ),
        
        // EDITAR PROJETO
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
        
        // ⭐ FONTES DE RECURSOS (Regra 7)
        GoRoute(
          path: 'fontes',
          name: 'fontes-recursos',
          pageBuilder: (context, state) => const MaterialPage(
            child: FontesBaseListScreen(),
          ),
          routes: [
            // ⭐ ROTAS ESPECÍFICAS - DEVEM VIR PRIMEIRO
            GoRoute(
              path: 'novo',
              name: 'nova-fonte',
              pageBuilder: (context, state) => const MaterialPage(
                child: FontesBaseFormScreen(),
              ),
            ),
            GoRoute(
              path: 'editar/:id',
              name: 'editar-fonte',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return MaterialPage(
                  child: FontesBaseFormScreen(fonteId: id),
                );
              },
            ),
            // ⭐ ALOCAÇÕES - DEVEM VIR ANTES DE :id
            GoRoute(
              path: 'alocacoes',
              name: 'alocacoes',
              pageBuilder: (context, state) => const MaterialPage(
                child: AlocacaoPesquisaScreen(),
              ),
            ),
            GoRoute(
              path: 'alocacao/novo',
              name: 'nova-alocacao',
              pageBuilder: (context, state) => const MaterialPage(
                child: FonteAlocacaoFormScreen(),
              ),
            ),
            GoRoute(
              path: 'alocacao/editar/:id',
              name: 'editar-alocacao',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return MaterialPage(
                  child: FonteAlocacaoFormScreen(alocacaoId: id),
                );
              },
            ),
            // ⭐ DETALHES DA FONTE - DEVE VIR POR ÚLTIMO
            GoRoute(
              path: ':id',
              name: 'detalhe-fonte',
              pageBuilder: (context, state) {
                final id = state.pathParameters['id']!;
                return MaterialPage(
                  child: FontesBaseDetailScreen(fonteId: id),
                );
              },
            ),
          ],
        ),
        
        // ⭐ CONTRA PARTIDAS (Regra 11)
        GoRoute(
          path: 'contra-partidas',
          name: 'contra-partidas',
          pageBuilder: (context, state) => const MaterialPage(
            child: ContraPartidaListScreen(),
          ),
          routes: [
            GoRoute(
              path: 'novo',
              name: 'nova-contra-partida',
              pageBuilder: (context, state) => const MaterialPage(
                child: ContraPartidaFormScreen(),
              ),
            ),
            GoRoute(
              path: 'editar/:id',
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
        
        // ⭐ DETALHES DO PROJETO - DEVE VIR POR ÚLTIMO
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