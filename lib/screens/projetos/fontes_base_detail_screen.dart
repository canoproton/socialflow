/// ============================================
/// TELA: Detalhes da Fonte de Recurso
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../models/projetos/fonte_alocacao_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../theme/app_theme.dart';

class FontesBaseDetailScreen extends StatefulWidget {
  final String fonteId;

  const FontesBaseDetailScreen({super.key, required this.fonteId});

  @override
  State<FontesBaseDetailScreen> createState() => _FontesBaseDetailScreenState();
}

class _FontesBaseDetailScreenState extends State<FontesBaseDetailScreen> {
  final FontesBaseService _service = FontesBaseService();
  FontesBaseModel? _fonte;
  List<FonteAlocacaoModel> _alocacoes = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _fonte = await _service.getById(widget.fonteId);
      if (_fonte != null) {
        _alocacoes = await _service.getAlocacoes(widget.fonteId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatCurrency(double value) {
    return NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$').format(value);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não definida';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _fonte == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fonte de Recurso'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.go('/projetos/fontes'),
            tooltip: 'Voltar',
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
              const SizedBox(height: 16),
              Text(_error ?? 'Fonte não encontrada'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _carregarDados,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Fonte'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/projetos/fontes'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => context.go('/projetos/fontes/editar/${_fonte!.id}'),
            tooltip: 'Editar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ⭐ DADOS DA FONTE
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _fonte!.descricao,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfo('Entidade', _fonte!.entidade),
                    _buildInfo(
                      'Valor do Recurso',
                      _formatCurrency(_fonte!.valorRecurso),
                      color: Colors.green,
                    ),
                    if (_fonte!.remanejamento != null)
                      _buildInfo(
                        'Remanejamento',
                        '${_fonte!.remanejamento}%',
                      ),
                    if (_fonte!.dataAprovacao != null)
                      _buildInfo(
                        'Data de Aprovação',
                        _formatDate(_fonte!.dataAprovacao),
                      ),
                    if (_fonte!.obs != null && _fonte!.obs!.isNotEmpty)
                      _buildInfo('Observações', _fonte!.obs!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ⭐ AÇÕES
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/projetos/fontes/alocacao/novo?fonteId=${_fonte!.id}');
                    },
                    icon: const Icon(Icons.attach_money),
                    label: const Text('Nova Alocação'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.go('/projetos/fontes/alocacoes?fonteId=${_fonte!.id}');
                    },
                    icon: const Icon(Icons.list),
                    label: const Text('Ver Alocações'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ⭐ RESUMO FINANCEIRO
            Card(
              color: Colors.green.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildResumoItem(
                      'Total',
                      _formatCurrency(_fonte!.valorRecurso),
                      Colors.green,
                    ),
                    _buildResumoItem(
                      'Alocado',
                      _formatCurrency(_calcularTotalAlocado()),
                      Colors.orange,
                    ),
                    _buildResumoItem(
                      'Saldo',
                      _formatCurrency(_fonte!.valorRecurso - _calcularTotalAlocado()),
                      _fonte!.valorRecurso - _calcularTotalAlocado() >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfo(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: color ?? AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResumoItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
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
    );
  }

  double _calcularTotalAlocado() {
    double total = 0;
    for (var alocacao in _alocacoes) {
      total += alocacao.valorAlocado;
    }
    return total;
  }
}