/// ============================================
/// TELA: Lista de Empresas
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/operacional/empresa_provider.dart';
import '../../models/operacional/empresa_model.dart';
import '../../theme/app_theme.dart';

class EmpresaListScreen extends StatefulWidget {
  const EmpresaListScreen({super.key});

  @override
  State<EmpresaListScreen> createState() => _EmpresaListScreenState();
}

class _EmpresaListScreenState extends State<EmpresaListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EmpresaProvider>().loadEmpresas();
    });
  }

  // ⭐ CORRIGIDO: Usar context.go com verificação mounted
  void _goBack() {
    if (mounted) {
      context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Empresas - Operacional'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
          tooltip: 'Voltar para o Dashboard',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/operacional/empresas/novo'),
            tooltip: 'Nova Empresa',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<EmpresaProvider>().loadEmpresas(),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Consumer<EmpresaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.empresas.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando empresas...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadEmpresas(),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          if (provider.empresas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.business_outlined, size: 64, color: AppTheme.textLight),
                  const SizedBox(height: 16),
                  const Text('Nenhuma empresa cadastrada'),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => context.go('/operacional/empresas/novo'),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Primeira Empresa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadEmpresas(),
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.empresas.length,
              itemBuilder: (context, index) {
                final empresa = provider.empresas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryColor,
                      child: Text(
                        empresa.initials,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(empresa.nome, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qualif: ${empresa.qualifLabel}', style: const TextStyle(fontSize: 12)),
                        if (empresa.cnpj != null && empresa.cnpj!.isNotEmpty)
                          Text('CNPJ: ${empresa.cnpjFormatado}', style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          onPressed: () => context.go('/operacional/empresas/editar/${empresa.id}'),
                          tooltip: 'Editar',
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20, color: AppTheme.dangerColor),
                          onPressed: () => _confirmDelete(empresa),
                          tooltip: 'Excluir',
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(EmpresaModel empresa) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Tem certeza que deseja excluir a empresa "${empresa.nome}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.dangerColor),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<EmpresaProvider>();
      final success = await provider.deleteEmpresa(empresa.id);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Empresa "${empresa.nome}" excluída!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    }
  }
}
