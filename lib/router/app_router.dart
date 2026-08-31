import 'package:go_router/go_router.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/operacional/operacional_index_screen.dart';
import '../screens/operacional/empresa_unified_screen.dart';
import '../screens/operacional/contato_unified_screen.dart';
import '../screens/projetos/projeto_list_screen.dart';
import '../screens/projetos/projeto_form_screen.dart';
import '../screens/projetos/projeto_detail_screen.dart';
import '../screens/projetos/contra_partida_list_screen.dart';
import '../screens/projetos/contra_partida_form_screen.dart';

// ✅ Módulo Fontes
import '../screens/fontes/fontes_base_list_screen.dart';
import '../screens/fontes/fontes_base_form_screen.dart';
import '../screens/fontes/fontes_pesquisa_screen.dart';
import '../screens/fontes/fontes_alocacao_screen.dart';
import '../screens/fontes/fontes_extrato_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/login',
    routes: [
      // Auth
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Home
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Operacional
      GoRoute(
        path: '/operacional',
        builder: (context, state) => const OperacionalIndexScreen(),
      ),
      GoRoute(
        path: '/operacional/empresa',
        builder: (context, state) => const EmpresaUnifiedScreen(),
      ),
      GoRoute(
        path: '/operacional/contato',
        builder: (context, state) => const ContatoUnifiedScreen(),
      ),

      // Projetos
      GoRoute(
        path: '/projetos',
        builder: (context, state) => const ProjetoListScreen(),
      ),
      GoRoute(
        path: '/projetos/novo',
        builder: (context, state) => const ProjetoFormScreen(),
      ),
      GoRoute(
        path: '/projetos/editar/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjetoFormScreen(projetoId: id);
        },
      ),
      GoRoute(
        path: '/projetos/detalhe/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ProjetoDetailScreen(projetoId: id);
        },
      ),
      GoRoute(
        path: '/projetos/contra-partida/:projetoId',
        builder: (context, state) {
          // final projetoId = state.pathParameters['projetoId']!;
          return const ContraPartidaListScreen();
        },
      ),
      GoRoute(
        path: '/projetos/contra-partida/novo',
        builder: (context, state) {
          return const ContraPartidaFormScreen();
        },
      ),

      // ✅ Módulo Fontes
      GoRoute(
        path: '/fontes',
        builder: (context, state) => const FontesBaseListScreen(),
      ),
      GoRoute(
        path: '/fontes/novo',
        builder: (context, state) => const FontesBaseFormScreen(),
      ),
      GoRoute(
        path: '/fontes/editar/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return FontesBaseFormScreen(fonteId: id);
        },
      ),
      GoRoute(
        path: '/fontes/pesquisar',
        builder: (context, state) => const FontesPesquisaScreen(),
      ),
      GoRoute(
        path: '/fontes/alocar',
        builder: (context, state) => const FontesAlocacaoScreen(),
      ),
      GoRoute(
        path: '/fontes/alocar/:fonteId',
        builder: (context, state) {
          final fonteId = state.pathParameters['fonteId']!;
          return FontesAlocacaoScreen(fonteId: fonteId);
        },
      ),
      GoRoute(
        path: '/fontes/extrato/:fonteId',
        builder: (context, state) {
          final fonteId = state.pathParameters['fonteId']!;
          return FontesExtratoScreen(fonteId: fonteId);
        },
      ),
    ],
  );
}