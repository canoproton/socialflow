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
  ],
);