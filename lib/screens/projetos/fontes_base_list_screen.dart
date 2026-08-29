/// ============================================
/// TELA: Lista de Fontes de Recursos (com Resumo)
/// REGRA 7
/// ============================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/projetos/fontes_base_model.dart';
import '../../services/projetos/fontes_base_service.dart';
import '../../theme/app_theme.dart';

class FontesBaseListScreen extends StatefulWidget {
  const FontesBaseListScreen({super.key});

  @override
  State<FontesBaseListScreen> createState() => _FontesBaseListScreenState();
}

class _FontesBaseListScreenState extends State<FontesBaseListScreen> {
  final FontesBaseService _service = FontesBaseService();
  List<FontesBaseModel> _fontes = [];
  bool _isLoading = false;
  String? _error;

  // ⭐ RESUMO
  double _totalGeral = 0;
  double _totalAlocadoGeral = 0;

  @override
  void initState() {
    super.initState();
    _carregarFontes();
  }

  Future<void> _carregarFontes() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      _fontes = await _service.list();
      
      // ⭐ CALCULAR TOTAIS GERAIS
      _totalGeral = 0;
      _totalAlocadoGeral = 0;
      for (var fonte in _fontes) {
        _totalGeral += fonte.valorRecurso;
        _totalAlocadoGeral += fonte.totalAlocado;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fontes de Recursos'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/'),
          tooltip: 'Voltar',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.go('/projetos/fontes/novo'),
            tooltip: 'Nova Fonte',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarFontes,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _carregarFontes,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    if (_fontes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.attach_money, size: 64, color: AppTheme.textLight),
            const SizedBox(height: 16),
            const Text('Nenhuma fonte de recurso cadastrada'),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => context.go('/projetos/fontes/novo'),
              icon: const Icon(Icons.add),
              label: const Text('Cadastrar Fonte'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ⭐ RESUMO GERAL
        _buildResumoGeral(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _fontes.length,
            itemBuilder: (context, index) {
              final fonte = _fontes[index];
              return _buildFonteCard(fonte);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildResumoGeral() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumoItem(
            'Total Geral',
            _formatCurrency(_totalGeral),
            Colors.blue,
          ),
          _buildResumoItem(
            'Total Alocado',
            _formatCurrency(_totalAlocadoGeral),
            Colors.orange,
          ),
          _buildResumoItem(
            'Saldo Geral',
            _formatCurrency(_totalGeral - _totalAlocadoGeral),
            (_totalGeral - _totalAlocadoGeral) >= 0 ? Colors.green : Colors.red,
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
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFonteCard(FontesBaseModel fonte) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        onTap: () => context.go('/projetos/fontes/${fonte.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fonte.descricao,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Entidade: ${fonte.entidade}',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () => context.go('/projetos/fontes/editar/${fonte.id}'),
                    tooltip: 'Editar',
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _confirmDelete(fonte),
                    tooltip: 'Excluir',
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ⭐ RESUMO DA FONTE (Total, Alocado, Saldo)
              Row(
                children: [
                  _buildFonteResumoItem(
                    'Total',
                    _formatCurrency(fonte.valorRecurso),
                    Colors.blue,
                  ),
                  _buildFonteResumoItem(
                    'Alocado',
                    _formatCurrency(fonte.totalAlocado),
                    Colors.orange,
                  ),
                  _buildFonteResumoItem(
                    'Saldo',
                    _formatCurrency(fonte.saldo),
                    fonte.saldo >= 0 ? Colors.green : Colors.red,
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // ⭐ BARRA DE PROGRESSO
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: fonte.percentualAlocado / 100,
                  backgroundColor: Colors.grey[200],
                  minHeight: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    fonte.percentualAlocado >= 80
                        ? Colors.orange
                        : fonte.percentualAlocado >= 100
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${fonte.percentualAlocado.toStringAsFixed(1)}% alocado',
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
              ),

              if (fonte.dataAprovacao != null)
                Text(
                  'Aprovação: ${_formatDate(fonte.dataAprovacao)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFonteResumoItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(FontesBaseModel fonte) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a fonte "${fonte.descricao}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _service.delete(fonte.id);
                await _carregarFontes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Fonte excluída com sucesso!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erro: ${e.toString()}'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}