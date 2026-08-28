import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({super.key});

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
          _buildMenuItem(context, Icons.dashboard, 'Dashboard', '/'),
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
          _buildMenuItem(context, Icons.people, 'Usuários', '/usuarios', true),
          // ⭐ PROJETOS (com submenu)
          _buildMenuItem(
            context,
            Icons.folder,
            'Projetos',
            '/projetos',
          ),
          _buildMenuItem(
            context,
            Icons.attach_money,
            'Fontes de Recursos',
            '/projetos/fontes',
          ),
          _buildMenuItem(
            context,
            Icons.swap_horiz,
            'Contra Partidas',
            '/projetos/contra-partidas',
          ),
          _buildMenuItem(context, Icons.checklist, 'Tarefas', '/tarefas', true),
          
          // ⭐ OPERACIONAL - SUBMENU
          _buildSubmenuItem(context),
          
          _buildMenuItem(context, Icons.account_balance, 'Contabilidade', '/contabilidade', true),
          _buildMenuItem(context, Icons.attach_money, 'Financeiro', '/financeiro', true),
          _buildMenuItem(context, Icons.folder_open, 'Documentos', '/documentos', true),
          _buildMenuItem(context, Icons.settings_overscan, 'IA', '/ia', true),
          const Divider(),
          _buildMenuItem(context, Icons.settings, 'Configurações', '/configuracoes', true),
        ],
      ),
    );
  }

  Widget _buildSubmenuItem(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.business_center, color: AppTheme.primaryColor),
      title: const Text('Operacional'),
      children: [
        _buildMenuItem(context, Icons.business, 'Empresas', '/operacional/empresas'),
        _buildMenuItem(context, Icons.people, 'Contatos', '/operacional/contatos'),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    String route, [
    bool isDisabled = false,
  ]) {
    final isActive = !isDisabled &&
        (GoRouterState.of(context).uri.path == route ||
            (route != '/' &&
                GoRouterState.of(context).uri.path.startsWith(route)));

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
      onTap: isDisabled ? null : () => context.go(route),
    );
  }
}