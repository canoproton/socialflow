// Adicione estas importações
import 'screens/alocacoes/alocacao_pesquisa_screen.dart';
import 'screens/alocacoes/alocacao_extrato_screen.dart';
import 'screens/alocacoes/alocacao_form_screen.dart';

// Adicione estas rotas no GoRouter
GoRouter(
  routes: [
    // ... outras rotas
    GoRoute(
      path: '/alocacoes',
      builder: (context, state) => const AlocacaoPesquisaScreen(),
    ),
    GoRoute(
      path: '/alocacoes/extrato/:fonteId',
      builder: (context, state) {
        final fonteId = state.pathParameters['fonteId']!;
        return AlocacaoExtratoScreen(fonteId: fonteId);
      },
    ),
    GoRoute(
      path: '/alocacoes/nova/:fonteId',
      builder: (context, state) {
        final fonteId = state.pathParameters['fonteId']!;
        return AlocacaoFormScreen(fonteId: fonteId);
      },
    ),
  ],
);