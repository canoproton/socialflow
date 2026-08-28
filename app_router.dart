final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Home
    GoRoute(
      path: '/',
      name: 'home',
      pageBuilder: (context, state) => const MaterialPage(
        child: HomeScreen(),
      ),
    ),
    
    // ⭐ MÓDULO OPERACIONAL (JÁ EXISTE)
    GoRoute(
      path: '/operacional',
      name: 'operacional',
      pageBuilder: (context, state) => MaterialPage(
        child: ChangeNotifierProvider(
          create: (_) => EmpresaProvider(), // Seu provider existente
          child: const EmpresaListScreen(), // Sua tela existente
        ),
      ),
    ),
    
    // ⭐ MÓDULO PROJETOS (NOVO)
    GoRoute(
      path: '/projetos',
      name: 'projetos',
      pageBuilder: (context, state) => MaterialPage(
        child: ChangeNotifierProvider(
          create: (_) => ProjetoProvider(),
          child: const ProjetoListScreen(),
        ),
      ),
      routes: [...], // Sub-rotas do projetos
    ),
    // ⭐ ALOCAÇÕES (Regra 7)
    GoRoute(
      path: 'alocacoes',
      name: 'alocacoes',
      pageBuilder: (context, state) => const MaterialPage(
        child: FonteAlocacaoListScreen(),
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
  ],
);