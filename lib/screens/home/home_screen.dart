import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/main_menu.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const MainMenu(),
      appBar: AppBar(
        title: const Text('SocialFlow'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            tooltip: 'Sair',
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.dashboard,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              const Text(
                'Bem-vindo ao SocialFlow',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecione um módulo no menu lateral',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: [
                  _buildModuleCard(
                    context,
                    icon: Icons.people,
                    label: 'Usuários',
                    route: '/usuarios',
                    isDisabled: true,
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.folder,
                    label: 'Projetos',
                    route: '/projetos',
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.checklist,
                    label: 'Tarefas',
                    route: '/tarefas',
                    isDisabled: true,
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.business_center,
                    label: 'Operacional',
                    route: '/operacional',
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.account_balance,
                    label: 'Contabilidade',
                    route: '/contabilidade',
                    isDisabled: true,
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.attach_money,
                    label: 'Financeiro',
                    route: '/financeiro',
                    isDisabled: true,
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.folder_open,
                    label: 'Documentos',
                    route: '/documentos',
                    isDisabled: true,
                  ),
                  _buildModuleCard(
                    context,
                    icon: Icons.settings_overscan,
                    label: 'IA',
                    route: '/ia',
                    isDisabled: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModuleCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    bool isDisabled = false,
  }) {
    return Card(
      elevation: isDisabled ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                context.go(route);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 110,
          height: 110,
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: isDisabled ? AppTheme.textLight : AppTheme.primaryColor,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isDisabled ? AppTheme.textLight : AppTheme.textPrimary,
                ),
              ),
              if (isDisabled) ...[
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: AppTheme.textLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Em breve',
                    style: TextStyle(
                      fontSize: 8,
                      color: AppTheme.textLight,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}