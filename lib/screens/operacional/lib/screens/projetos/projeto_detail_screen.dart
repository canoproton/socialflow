/// ============================================
/// TELA: Detalhes do Projeto
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/projetos/projeto_provider.dart';
import '../../models/projetos/projeto_model.dart';
import '../../models/projetos/meta_model.dart';
import '../../models/projetos/etapa_model.dart';
import '../../theme/app_theme.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProjetoProvider>().loadProjetoCompleto(widget.projetoId);
    });
  }

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
            onPressed: () => context.go('/projetos/editar/${widget.projetoId}'),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _imprimirProjeto(context),
            tooltip: 'Imprimir/PDF',
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
                    onPressed: () => provider.loadProjetoCompleto(widget.projetoId),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(projeto),
                const SizedBox(height: 16),
                _buildResumo(projeto),
                const SizedBox(height: 16),
                _buildMetas(projeto),
                const SizedBox(height: 16),
                _buildActionButtons(projeto),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ProjetoModel projeto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    projeto.descricao ?? 'Sem título',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(projeto.statusLabel),
                  backgroundColor: projeto.statusColor.withOpacity(0.2),
                  labelStyle: TextStyle(color: projeto.statusColor),
                ),
              ],
            ),
            const Divider(),
            if (projeto.processo != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.receipt, size: 16, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text('Processo: ${projeto.processo}'),
                  ],
                ),
              ),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Entrega: ${_formatDate(projeto.dataEntrega)}'),
                const SizedBox(width: 24),
                const Icon(Icons.check_circle, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Aprovação: ${_formatDate(projeto.dataAprovacao)}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumo(ProjetoModel projeto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumo Financeiro',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: _buildResumoItem(
                    'Valor Estimado',
                    'R\$ ${projeto.valorEstimado?.toStringAsFixed(2) ?? '0,00'}',
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildResumoItem(
                    'Valor Aprovado',
                    'R\$ ${projeto.valorAprovado?.toStringAsFixed(2) ?? '0,00'}',
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildResumoItem(
                    'Total Metas',
                    'R\$ ${projeto.valorTotalMetas?.toStringAsFixed(2) ?? '0,00'}',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildResumoItem(
                    'Saldo Projeto',
                    'R\$ ${projeto.saldoProjeto?.toStringAsFixed(2) ?? '0,00'}',
                    projeto.saldoProjeto != null && projeto.saldoProjeto! >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetas(ProjetoModel projeto) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Metas (${projeto.metas.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const Divider(),
            if (projeto.metas.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: Text('Nenhuma meta cadastrada'),
                ),
              )
            else
              ...projeto.metas.map((meta) => _buildMetaItem(meta)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(MetaModel meta) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    meta.descricao ?? 'Sem descrição',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${meta.vlMetaAprov?.toStringAsFixed(2) ?? '0,00'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (meta.indicador != null)
              Text('Indicador: ${meta.indicador}'),
            if (meta.unidade != null)
              Text('Unidade: ${meta.unidade}'),
            
            const SizedBox(height: 8),
            
            // Etapas da Meta
            if (meta.etapas.isNotEmpty) ...[
              const Text(
                'Etapas:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              ...meta.etapas.map((etapa) => _buildEtapaItem(etapa)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEtapaItem(EtapaModel etapa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapa.descricao ?? 'Sem descrição',
                  style: const TextStyle(fontSize: 14),
                ),
                if (etapa.valorUnitario != null && etapa.quantidade != null)
                  Text(
                    '${etapa.valorUnitario} x ${etapa.quantidade} = R\$ ${etapa.valorEtapa?.toStringAsFixed(2) ?? '0,00'}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),
          Chip(
            label: Text(etapa.statusLabel),
            backgroundColor: etapa.statusColor.withOpacity(0.2),
            labelStyle: TextStyle(color: etapa.statusColor, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ProjetoModel projeto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projetos/editar/${projeto.id}'),
          icon: const Icon(Icons.edit),
          label: const Text('Editar'),
        ),
        const SizedBox(width: 16),
        if (projeto.statusProjeto == ProjetoModel.STATUS_APROVADO)
          ElevatedButton.icon(
            onPressed: () => _executarProjeto(context, projeto.id),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Executar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (projeto.statusProjeto == ProjetoModel.STATUS_EXECUTANDO)
          ElevatedButton.icon(
            onPressed: () => _imprimirProjeto(context),
            icon: const Icon(Icons.print),
            label: const Text('Imprimir/PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }

  // ============================================
  // AUXILIARES
  // ============================================

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _executarProjeto(BuildContext context, String projetoId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Execução'),
        content: const Text(
          'Ao executar o projeto, todas as etapas serão disparadas para Tickets e ItemLancamento. Deseja continuar?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Executar', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<ProjetoProvider>();
      final success = await provider.aprovarProjeto(projetoId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Projeto executado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _imprimirProjeto(BuildContext context) {
    // TODO: Implementar impressão/PDF (Regra 14)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidade de impressão em desenvolvimento'),
      ),
    );
  }
}