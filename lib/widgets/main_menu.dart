import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue[800],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'SocialFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Sistema de Gestão',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildMenuItem(
            context,
            icon: Icons.home,
            title: 'Início',
            route: '/home',
          ),
          _buildDivider(),
          _buildSectionHeader('Módulos'),
          _buildMenuItem(
            context,
            icon: Icons.people,
            title: 'Operacional',
            route: '/operacional',
          ),
          _buildMenuItem(
            context,
            icon: Icons.folder,
            title: 'Projetos',
            route: '/projetos',
          ),
          // ✅ NOVO ITEM: Fontes de Recursos
          _buildMenuItem(
            context,
            icon: Icons.account_balance,
            title: 'Fontes de Recursos',
            route: '/fontes',
          ),
          _buildDivider(),
          _buildSectionHeader('Configurações'),
          _buildMenuItem(
            context,
            icon: Icons.person,
            title: 'Perfil',
            route: '/perfil',
          ),
          _buildMenuItem(
            context,
            icon: Icons.logout,
            title: 'Sair',
            route: '/logout',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue[800]),
      title: Text(title),
      onTap: () {
        Navigator.pop(context); // Fecha o drawer
        if (route == '/logout') {
          // TODO: Implementar logout
          context.go('/login');
        } else {
          context.go(route);
        }
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}