/// ============================================
/// TELA: HOME / DASHBOARD
/// ============================================
/// Exibe o menu principal com todas as aplicações
/// do sistema SocialFlow
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  String _userName = 'Usuário';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _userName = _authService.getUserName();
    _userEmail = _authService.getUserEmail();
  }

  /// ============================================
  /// LOGOUT
  /// ============================================
  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao sair: $e'),
            backgroundColor: AppTheme.dangerColor,
          ),
        );
      }
    }
  }

  /// ============================================
  /// NAVEGAÇÃO PARA MÓDULOS
  /// ============================================
  void _navigateTo(String route) {
    if (mounted) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialFlow'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: _logout,
            tooltip: 'Sair',
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: _buildBody(),
    );
  }

  /// ============================================
  /// CORPO DO DASHBOARD
  /// ============================================
  Widget _buildBody() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ícone do Dashboard
            const Icon(
              Icons.dashboard_outlined,
              size: 64,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(height: 16),

            // Saudação
            Text(
              'Bem-vindo(a), $_userName!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),

            // Subtítulo
            Text(
              'Sistema SocialFlow - Gestão de Projetos',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Informações do Usuário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    Icons.email_outlined,
                    'Email',
                    _userEmail,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.check_circle_outline,
                    'Status',
                    Supabase.instance.client.auth.currentSession != null
                        ? 'Autenticado'
                        : 'Não autenticado',
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.access_time_outlined,
                    'Sessão',
                    _authService.currentSession != null
                        ? 'Ativa'
                        : 'Inativa',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cards de Acesso Rápido
            Wrap(
              spacing: 16,
              runSpacing: 16,
              alignment: WrapAlignment.center,
              children: [
                _buildQuickAccessCard(
                  icon: Icons.folder_outlined,
                  title: 'Projetos',
                  color: Colors.blue,
                  onTap: () => _navigateTo('/projetos'),
                ),
                _buildQuickAccessCard(
                  icon: Icons.attach_money_outlined,
                  title: 'Financeiro',
                  color: Colors.green,
                  onTap: () => _navigateTo('/financeiro'),
                ),
                _buildQuickAccessCard(
                  icon: Icons.account_balance_outlined,
                  title: 'Contabilidade',
                  color: Colors.purple,
                  onTap: () => _navigateTo('/contabilidade'),
                ),
                _buildQuickAccessCard(
                  icon: Icons.folder_outlined,
                  title: 'Documentos',
                  color: Colors.orange,
                  onTap: () => _navigateTo('/documentos'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// LINHA DE INFORMAÇÃO
  /// ============================================
  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// ============================================
  /// CARD DE ACESSO RÁPIDO
  /// ============================================
  Widget _buildQuickAccessCard({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.backgroundWhite,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// MENU LATERAL (DRAWER)
  /// ============================================
  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            // ==========================================
            // CABEÇALHO DO DRAWER
            // ==========================================
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppTheme.primaryColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _userName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _userEmail,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ==========================================
            // ITENS DO MENU (9 APLICAÇÕES)
            // ==========================================
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // 1. Usuários
                  _buildDrawerItem(
                    icon: Icons.people_outlined,
                    title: 'Usuários',
                    route: '/usuarios',
                  ),
                  // 2. Projetos
                  _buildDrawerItem(
                    icon: Icons.folder_outlined,
                    title: 'Projetos',
                    route: '/projetos',
                  ),
                  // 3. Tarefas
                  _buildDrawerItem(
                    icon: Icons.checklist_outlined,
                    title: 'Tarefas',
                    route: '/tarefas',
                  ),
                  // 4. Operacional (submenu com Contatos e Empresas)
                  _buildDrawerSection(
                    title: 'Operacional',
                    icon: Icons.business_center_outlined,
                    children: [
                      _buildDrawerItem(
                        icon: Icons.people_outlined,
                        title: 'Contatos',
                        route: '/operacional/contatos',
                        indent: true,
                      ),
                      _buildDrawerItem(
                        icon: Icons.business_outlined,
                        title: 'Empresas',
                        route: '/operacional/empresas',
                        indent: true,
                      ),
                    ],
                  ),
                  // 5. Contabilidade
                  _buildDrawerItem(
                    icon: Icons.account_balance_outlined,
                    title: 'Contabilidade',
                    route: '/contabilidade',
                  ),
                  // 6. Financeiro
                  _buildDrawerItem(
                    icon: Icons.attach_money_outlined,
                    title: 'Financeiro',
                    route: '/financeiro',
                  ),
                  // 7. Documentos
                  _buildDrawerItem(
                    icon: Icons.folder_outlined,
                    title: 'Documentos',
                    route: '/documentos',
                  ),
                  // 8. IA
                  _buildDrawerItem(
                    icon: Icons.psychology_outlined,
                    title: 'IA',
                    route: '/ia',
                  ),
                  // 9. Dashboard
                  _buildDrawerItem(
                    icon: Icons.dashboard_outlined,
                    title: 'Dashboard',
                    route: '/home',
                  ),
                ],
              ),
            ),

            // ==========================================
            // RODAPÉ DO DRAWER
            // ==========================================
            Padding(
              padding: const EdgeInsets.all(16),
              child: const Text(
                'SocialFlow v2.0',
                style: TextStyle(
                  color: AppTheme.textLight,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ============================================
  /// ITEM DO MENU LATERAL (COM ROTA)
  /// ============================================
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required String route,
    bool indent = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontSize: indent ? 13 : 14,
          fontWeight: indent ? FontWeight.normal : FontWeight.w500,
        ),
      ),
      contentPadding: EdgeInsets.only(
        left: indent ? 48.0 : 16.0,
        right: 16.0,
      ),
      onTap: () {
        // Fecha o drawer
        Navigator.pop(context);
        // Navega para a rota
        if (mounted) {
          context.go(route);
        }
      },
      trailing: const Icon(
        Icons.arrow_forward_ios_outlined,
        size: 16,
        color: AppTheme.textLight,
      ),
    );
  }

  /// ============================================
  /// SEÇÃO DO MENU LATERAL (COM SUBITENS)
  /// ============================================
  Widget _buildDrawerSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Cabeçalho da seção
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
        ),
        // Subitens
        ...children,
        const Divider(height: 8),
      ],
    );
  }
}
