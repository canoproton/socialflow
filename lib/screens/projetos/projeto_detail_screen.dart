/// ============================================
/// TELA: Detalhes do Projeto (Simples)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';

class ProjetoDetailScreen extends StatelessWidget {
  final String projetoId;

  const ProjetoDetailScreen({super.key, required this.projetoId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/projetos/editar/$projetoId'),
          ),
        ],
      ),
      body: Consumer<ProjetoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadProjetoById(projetoId),
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final projeto = provider.selectedProjeto;
          if (projeto == null) {
            return const Center(child: Text('Projeto não encontrado'));
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projeto.descricao ?? 'Sem título',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(),
                    _buildInfo('Status', projeto.statusLabel),
                    _buildInfo('Processo', projeto.processo ?? 'N/A'),
                    _buildInfo('Valor Total Metas', 'R\$ ${projeto.valorTotalMetas?.toStringAsFixed(2) ?? '0,00'}'),
                    _buildInfo('Saldo Projeto', 'R\$ ${projeto.saldoProjeto?.toStringAsFixed(2) ?? '0,00'}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfo(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}