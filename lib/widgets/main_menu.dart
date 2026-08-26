import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainMenu extends StatelessWidget {
  final bool isCollapsed;

  const MainMenu({super.key, this.isCollapsed = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Text(
                  'SocialFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Sistema de Gestão',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          
          // Dashboard
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/',
          ),
          
          // Separador
          const Divider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'MÓDULOS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.textLight,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // ✅ Operacional (Já existe)
          _buildMenuItem(
            context,
            icon: Icons.business,
            label: 'Operacional',
            route: '/operacional',
          ),
          
          // ✅ Projetos (Em andamento)
          _buildMenuItem(
            context,
            icon: Icons.folder,
            label: 'Projetos',
            route: '/projetos',
          ),
          
          // 🔜 Tarefas (Próximo)
          _buildMenuItem(
            context,
            icon: Icons.task,
            label: 'Tarefas',
            route: '/tarefas',
            isDisabled: true, // Desabilitado até implementar
          ),
          
          // 🔜 Financeiro (Futuro)
          _buildMenuItem(
            context,
            icon: Icons.attach_money,
            label: 'Financeiro',
            route: '/financeiro',
            isDisabled: true,
          ),
          
          const Divider(),
          
          // Configurações
          _buildMenuItem(
            context,
            icon: Icons.settings,
            label: 'Configurações',
            route: '/configuracoes',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    bool isDisabled = false,
  }) {
    final isActive = !isDisabled && 
        (GoRouterState.of(context).uri.path == route ||
        (route != '/' && GoRouterState.of(context).uri.path.startsWith(route)));

    return ListTile(
      leading: Icon(
        icon,
        color: isDisabled 
            ? AppTheme.textLight 
            : (isActive ? AppTheme.primaryColor : AppTheme.textSecondary),
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isDisabled 
              ? AppTheme.textLight 
              : (isActive ? AppTheme.primaryColor : AppTheme.textPrimary),
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? AppTheme.primaryColor.withOpacity(0.08) : null,
      onTap: isDisabled 
          ? null 
          : () {
              context.go(route);
              Navigator.pop(context);
            },
    );
  }
}