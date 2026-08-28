/// ============================================
/// TELA: Detalhes do Projeto (Layout Profissional)
/// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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

  String _formatCurrency(double? value) {
    if (value == null) return 'R\$ 0,00';
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ORÇAMENTO':
        return Colors.orange;
      case 'EMITIDO':
        return Colors.blue;
      case 'APROVADO':
        return Colors.green;
      case 'INDEFERIDO':
        return Colors.red;
      case 'EXECUTANDO':
        return Colors.purple;
      case 'FINALIZADO':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _getEtapaStatusColor(String status) {
    switch (status) {
      case 'PLANEJADA':
        return Colors.grey;
      case 'ACIONADO':
        return Colors.orange;
      case 'EXECUÇÃO':
        return Colors.blue;
      case 'PENDENTE':
        return Colors.purple;
      case 'CONCLUIDA':
        return Colors.green;
      case 'CANCELADA':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Projeto'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.go('/projetos/editar/${widget.projetoId}'),
            tooltip: 'Editar',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () {
              // TODO: Implementar PDF (Regra 14)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de PDF em desenvolvimento'),
                ),
              );
            },
            tooltip: 'Exportar PDF',
          ),
        ],
      ),
      body: Consumer<ProjetoProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Carregando projeto...'),
                ],
              ),
            );
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
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
            return const Center(
              child: Text('Projeto não encontrado'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ⭐ HEADER DO PROJETO
                _buildHeader(projeto),
                const SizedBox(height: 16),

                // ⭐ RESUMO FINANCEIRO
                _buildFinancialSummary(projeto),
                const SizedBox(height: 16),

                // ⭐ INFORMAÇÕES ADICIONAIS
                _buildAdditionalInfo(projeto),
                const SizedBox(height: 16),

                // ⭐ METAS E ETAPAS
                _buildMetasSection(projeto),
                const SizedBox(height: 16),

                // ⭐ BOTÕES DE AÇÃO
                _buildActionButtons(projeto),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // HEADER DO PROJETO
  // ============================================

  Widget _buildHeader(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    projeto.descricao ?? 'Projeto sem título',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(projeto.statusProjeto).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(projeto.statusProjeto),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    projeto.statusLabel,
                    style: TextStyle(
                      color: _getStatusColor(projeto.statusProjeto),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (projeto.processo != null)
              Row(
                children: [
                  Icon(Icons.receipt, size: 16, color: AppTheme.textSecondary),
                  const SizedBox(width: 8),
                  Text(
                    'Processo: ${projeto.processo}',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Entrega: ${_formatDate(projeto.dataEntrega)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 24),
                Icon(Icons.check_circle, size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Text(
                  'Aprovação: ${_formatDate(projeto.dataAprovacao)}',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // RESUMO FINANCEIRO
  // ============================================

  Widget _buildFinancialSummary(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceItem(
                    'Valor Estimado',
                    _formatCurrency(projeto.valorEstimado),
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildFinanceItem(
                    'Valor Aprovado',
                    _formatCurrency(projeto.valorAprovado),
                    Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildFinanceItem(
                    'Total Metas',
                    _formatCurrency(projeto.valorTotalMetas),
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildFinanceItem(
                    'Saldo Projeto',
                    _formatCurrency(projeto.saldoProjeto),
                    (projeto.saldoProjeto ?? 0) >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceItem(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
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

  // ============================================
  // INFORMAÇÕES ADICIONAIS
  // ============================================

  Widget _buildAdditionalInfo(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Adicionais',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Gerente',
                    projeto.gerenteProjetoId ?? 'Não definido',
                    Icons.person,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Proponente',
                    projeto.proponenteId ?? 'Não definido',
                    Icons.business,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (projeto.obs != null && projeto.obs!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: _buildInfoItem(
                  'Observações',
                  projeto.obs!,
                  Icons.comment,
                  isLongText: true,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon, {bool isLongText = false}) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isLongText ? FontWeight.normal : FontWeight.w500,
                  ),
                  maxLines: isLongText ? 3 : 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // METAS E ETAPAS
  // ============================================

  Widget _buildMetasSection(ProjetoModel projeto) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Metas e Etapas',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${projeto.metas.length} metas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            if (projeto.metas.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'Nenhuma meta cadastrada',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...projeto.metas.asMap().entries.map((entry) {
                final index = entry.key;
                final meta = entry.value;
                return _buildMetaItem(meta, index + 1);
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaItem(MetaModel meta, int number) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da Meta
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$number',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          meta.descricao ?? 'Meta sem descrição',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    'R\$ ${meta.vlMetaAprov?.toStringAsFixed(2) ?? '0,00'}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: Colors.green.withOpacity(0.15),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Indicadores da Meta
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (meta.indicador != null && meta.indicador!.isNotEmpty)
                  _buildTag('📊 ${meta.indicador}', Colors.blue),
                if (meta.unidade != null && meta.unidade!.isNotEmpty)
                  _buildTag('📏 ${meta.unidade}', Colors.purple),
                if (meta.publicoAlvo != null && meta.publicoAlvo!.isNotEmpty)
                  _buildTag('👥 ${meta.publicoAlvo}', Colors.green),
                if (meta.local != null && meta.local!.isNotEmpty)
                  _buildTag('📍 ${meta.local}', Colors.orange),
                if (meta.prova != null && meta.prova!.isNotEmpty)
                  _buildTag('📄 ${meta.prova}', Colors.cyan),
              ],
            ),
            const SizedBox(height: 12),

            // Etapas da Meta
            if (meta.etapas.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Etapas (${meta.etapas.length})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        Text(
                          'Total: R\$ ${meta.valorTotalEtapas?.toStringAsFixed(2) ?? '0,00'}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[700],
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    ...meta.etapas.map((etapa) => _buildEtapaItem(etapa)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildEtapaItem(EtapaModel etapa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 32,
            decoration: BoxDecoration(
              color: _getEtapaStatusColor(etapa.status),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  etapa.descricao ?? 'Etapa sem descrição',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      'R\$ ${etapa.valorEtapa?.toStringAsFixed(2) ?? '0,00'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (etapa.dataInicio != null && etapa.dataVencimento != null)
                      Text(
                        '${_formatDate(etapa.dataInicio)} → ${_formatDate(etapa.dataVencimento)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _getEtapaStatusColor(etapa.status).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              etapa.statusLabel,
              style: TextStyle(
                fontSize: 11,
                color: _getEtapaStatusColor(etapa.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // BOTÕES DE AÇÃO
  // ============================================

  Widget _buildActionButtons(ProjetoModel projeto) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go('/projetos/editar/${projeto.id}'),
          icon: const Icon(Icons.edit, size: 18),
          label: const Text('Editar'),
        ),
        const SizedBox(width: 12),
        if (projeto.statusProjeto == ProjetoModel.STATUS_APROVADO)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar execução do projeto (Regra 8)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Executando projeto...'),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow, size: 18),
            label: const Text('Executar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        if (projeto.statusProjeto == ProjetoModel.STATUS_EXECUTANDO)
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implementar impressão/PDF (Regra 14)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Gerando PDF...'),
                ),
              );
            },
            icon: const Icon(Icons.picture_as_pdf, size: 18),
            label: const Text('Gerar PDF'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
      ],
    );
  }
}