import 'package:go_router/go_router.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';
import '../screens/operacional/contato_list_screen.dart';
import '../screens/operacional/contato_unified_screen.dart';
import '../screens/operacional/empresa_list_screen.dart';
import '../screens/operacional/empresa_unified_screen.dart';
import '../services/auth_service.dart';

class AppRouterSimple {
  static final AuthService _authService = AuthService();

  static GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isAuthenticated = _authService.isAuthenticated;

      if (isAuthenticated && state.matchedLocation == '/login') {
        return '/home';
      }

      if (!isAuthenticated && state.matchedLocation == '/home') {
        return '/login';
      }

      if (!isAuthenticated && state.matchedLocation == '/') {
        return '/login';
      }

      return null;
    },
    routes: [
      // Login
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // Dashboard
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      
      // ============================================
      // MÓDULO OPERACIONAL - CONTATOS
      // ============================================
      
      // Lista de Contatos
      GoRoute(
        path: '/operacional/contatos',
        name: 'operacional-contatos',
        builder: (context, state) => const ContatoListScreen(),
      ),
      
      // Novo Contato (Unificado)
      GoRoute(
        path: '/operacional/contatos/novo',
        name: 'operacional-contatos-novo',
        builder: (context, state) => const ContatoUnifiedScreen(),
      ),
      
      // Editar Contato (Unificado)
      GoRoute(
        path: '/operacional/contatos/editar/:id',
        name: 'operacional-contatos-editar',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ContatoUnifiedScreen(contatoId: id);
        },
      ),
      
      // ============================================
      // MÓDULO OPERACIONAL - EMPRESAS
      // ============================================
      
      // Lista de Empresas
      GoRoute(
        path: '/operacional/empresas',
        name: 'operacional-empresas',
        builder: (context, state) => const EmpresaListScreen(),
      ),
      
      // Nova Empresa (Unificado)
      GoRoute(
        path: '/operacional/empresas/novo',
        name: 'operacional-empresas-novo',
        builder: (context, state) => const EmpresaUnifiedScreen(),
      ),
      
      // Editar Empresa (Unificado)
      GoRoute(
        path: '/operacional/empresas/editar/:id',
        name: 'operacional-empresas-editar',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EmpresaUnifiedScreen(empresaId: id);
        },
      ),
    ],
  );
}
