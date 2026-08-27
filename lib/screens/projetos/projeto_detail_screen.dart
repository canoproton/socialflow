/// ============================================
/// TELA: Detalhes do Projeto
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../theme/app_theme.dart';
import '../../services/debug_service.dart';

class ProjetoDetailScreen extends StatefulWidget {
  final String projetoId;

  const ProjetoDetailScreen({super.key, required this.projetoId});

  @override
  State<ProjetoDetailScreen> createState() => _ProjetoDetailScreenState();
}

class _ProjetoDetailScreenState extends State<ProjetoDetailScreen> {
  @override
  void initState() {
    super.initState();
    DebugService.module('PROJETO DETAIL SCREEN');
    DebugService.log(
      module: 'PROJETO',
      action: 'INIT',
      data: 'projetoId: ${widget.projetoId}',
    );
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DebugService.log(
        module: 'PROJETO',
        action: 'LOAD',
        data: 'Carregando projeto completo ID: ${widget.projetoId}',
      );
      context.read<ProjetoProvider>().loadProjetoCompleto(widget.projetoId);
    });
  }

  @override
  Widget build(BuildContext context) {
    DebugService.log(
      module: 'PROJETO',
      action: 'BUILD',
      data: 'Construindo tela de detalhes',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            DebugService.log(
              module: 'PROJETO',
              action: 'VOLTAR',
              data: 'Voltando para lista de projetos',
            );
            context.go('/projetos');
          },
          tooltip: 'Voltar para lista de projetos',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              DebugService.log(
                module: 'PROJETO',
                action: 'EDITAR',
                data: 'Editando projeto ID: ${widget.projetoId}',
              );
              context.go('/projetos/editar/${widget.projetoId}');
            },
            tooltip: 'Editar projeto',
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              DebugService.log(
                module: 'PROJETO',
                action: 'EXCLUIR',
                data: 'Excluindo projeto ID: ${widget.projetoId}',
              );
              _confirmDelete(context);
            },
            tooltip: 'Excluir projeto',
          ),
        ],
      ),
      body: Consumer<ProjetoProvider>(
        builder: (context, provider, child) {
          DebugService.log(
            module: 'PROJETO',
            action: 'CONSUMER',
            data: 'isLoading: ${provider.isLoading}, hasError: ${provider.error != null}, hasData: ${provider.selectedProjeto != null}',
          );

          if (provider.isLoading) {
            DebugService.log(
              module: 'PROJETO',
              action: 'LOADING',
              data: 'Carregando...',
            );
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            DebugService.log(
              module: 'PROJETO',
              action: 'ERROR',
              data: provider.error,
              isError: true,
            );
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(provider.error!),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      DebugService.log(
                        module: 'PROJETO',
                        action: 'RETRY',
                        data: 'Tentando novamente',
                      );
                      provider.loadProjetoCompleto(widget.projetoId);
                    },
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          final projeto = provider.selectedProjeto;
          if (projeto == null) {
            DebugService.log(
              module: 'PROJETO',
              action: 'NOT_FOUND',
              data: 'Projeto não encontrado',
              isWarning: true,
            );
            return const Center(child: Text('Projeto não encontrado'));
          }

          DebugService.log(
            module: 'PROJETO',
            action: 'DADOS',
            data: 'Projeto: ${projeto.descricao}, Metas: ${projeto.metas.length}',
          );

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
                    if (projeto.metas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Metas do Projeto',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Divider(),
                      ...projeto.metas.map((meta) => _buildMetaItem(meta)),
                    ],
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

  Widget _buildMetaItem(meta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              meta.descricao ?? 'Sem descrição',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (meta.indicador != null)
              Text('Indicador: ${meta.indicador}'),
            if (meta.unidade != null)
              Text('Unidade: ${meta.unidade}'),
            Text(
              'Valor: R\$ ${meta.vlMetaAprov?.toStringAsFixed(2) ?? '0,00'}',
              style: const TextStyle(color: Colors.green),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir este projeto?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              DebugService.log(
                module: 'PROJETO',
                action: 'EXCLUIR_CONFIRMADO',
                data: 'Excluindo projeto ID: ${widget.projetoId}',
              );
              Navigator.pop(context);
              final success = await context.read<ProjetoProvider>().deleteProjeto(widget.projetoId);
              if (success && mounted) {
                DebugService.log(
                  module: 'PROJETO',
                  action: 'EXCLUIDO',
                  data: 'Projeto excluído com sucesso',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Projeto excluído com sucesso')),
                );
                context.go('/projetos');
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}