import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/main_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialFlow - Início'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const MainMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildModuleCard(
              context,
              icon: Icons.people,
              title: 'Operacional',
              subtitle: 'Gestão de Empresas e Contatos',
              color: Colors.blue[700]!,
              route: '/operacional',
            ),
            _buildModuleCard(
              context,
              icon: Icons.folder,
              title: 'Projetos',
              subtitle: 'Gestão de Projetos',
              color: Colors.green[700]!,
              route: '/projetos',
            ),
            // ✅ NOVO CARD: Fontes de Recursos
            _buildModuleCard(
              context,
              icon: Icons.account_balance,
              title: 'Fontes de Recursos',
              subtitle: 'Gestão de Fontes e Alocações',
              color: Colors.orange[700]!,
              route: '/fontes',
            ),
            _buildModuleCard(
              context,
              icon: Icons.attach_money,
              title: 'Financeiro',
              subtitle: 'Gestão Financeira',
              color: Colors.purple[700]!,
              route: '/financeiro',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required String route,
  }) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: color,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}