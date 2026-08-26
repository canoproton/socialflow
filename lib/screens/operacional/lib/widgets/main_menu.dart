/// ============================================
/// MENU PRINCIPAL
/// ============================================

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
              color: AppTheme.primaryColor,
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
          
          _buildMenuItem(
            context,
            icon: Icons.dashboard,
            label: 'Dashboard',
            route: '/',
          ),
          
          _buildMenuItem(
            context,
            icon: Icons.folder,
            label: 'Projetos',
            route: '/projetos',
          ),
          
          _buildMenuItem(
            context,
            icon: Icons.task,
            label: 'Tarefas',
            route: '/tarefas',
          ),
          
          _buildMenuItem(
            context,
            icon: Icons.people,
            label: 'Clientes',
            route: '/clientes',
          ),
          
          _buildMenuItem(
            context,
            icon: Icons.attach_money,
            label: 'Financeiro',
            route: '/financeiro',
          ),
          
          const Divider(),
          
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
  }) {
    final isActive = GoRouterState.of(context).uri.path == route ||
        (route != '/' && GoRouterState.of(context).uri.path.startsWith(route));

    return ListTile(
      leading: Icon(
        icon,
        color: isActive ? AppTheme.primaryColor : Colors.grey[600],
      ),
      title: Text(
        label,
        style: TextStyle(
          color: isActive ? AppTheme.primaryColor : Colors.grey[800],
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      tileColor: isActive ? AppTheme.primaryColor.withOpacity(0.1) : null,
      onTap: () {
        context.go(route);
        Navigator.pop(context);
      },
    );
  }
}